package main

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/yhonda-ohishi-pub-dev/cloudsql/internal/database"
)

var (
	cfgFile string
	dbType  string
)

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

var rootCmd = &cobra.Command{
	Use:   "migrate",
	Short: "CloudSQL migration tool",
	Long:  `A CLI tool for managing PostgreSQL and MySQL migrations on Google CloudSQL.`,
}

var upCmd = &cobra.Command{
	Use:   "up",
	Short: "Run all pending migrations",
	RunE: func(cmd *cobra.Command, args []string) error {
		return runMigration("up")
	},
}

var downCmd = &cobra.Command{
	Use:   "down",
	Short: "Rollback the last migration",
	RunE: func(cmd *cobra.Command, args []string) error {
		return runMigration("down")
	},
}

var downAllCmd = &cobra.Command{
	Use:   "down-all",
	Short: "Rollback all migrations",
	RunE: func(cmd *cobra.Command, args []string) error {
		return runMigration("down-all")
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show current migration version",
	RunE: func(cmd *cobra.Command, args []string) error {
		return runMigration("version")
	},
}

var forceCmd = &cobra.Command{
	Use:   "force [version]",
	Short: "Force set migration version",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return runMigration("force")
	},
}

var createCmd = &cobra.Command{
	Use:   "create [name]",
	Short: "Create a new migration file",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return createMigration(args[0])
	},
}

func init() {
	cobra.OnInitialize(initConfig)

	// Global flags
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is ./configs/config.yaml)")
	rootCmd.PersistentFlags().StringVar(&dbType, "db", "postgres", "database type (postgres or mysql)")

	// Database connection flags
	rootCmd.PersistentFlags().String("host", "localhost", "database host")
	rootCmd.PersistentFlags().Int("port", 5432, "database port")
	rootCmd.PersistentFlags().String("user", "", "database user")
	rootCmd.PersistentFlags().String("password", "", "database password (for local development)")
	rootCmd.PersistentFlags().String("database", "", "database name")
	rootCmd.PersistentFlags().String("sslmode", "disable", "SSL mode")

	// CloudSQL specific flags
	rootCmd.PersistentFlags().Bool("cloudsql", false, "use CloudSQL connection")
	rootCmd.PersistentFlags().String("project", "", "GCP project ID")
	rootCmd.PersistentFlags().String("region", "", "CloudSQL region")
	rootCmd.PersistentFlags().String("instance", "", "CloudSQL instance name")
	rootCmd.PersistentFlags().Bool("private-ip", false, "use private IP for CloudSQL")

	// Bind flags to viper
	viper.BindPFlag("host", rootCmd.PersistentFlags().Lookup("host"))
	viper.BindPFlag("port", rootCmd.PersistentFlags().Lookup("port"))
	viper.BindPFlag("user", rootCmd.PersistentFlags().Lookup("user"))
	viper.BindPFlag("password", rootCmd.PersistentFlags().Lookup("password"))
	viper.BindPFlag("database", rootCmd.PersistentFlags().Lookup("database"))
	viper.BindPFlag("sslmode", rootCmd.PersistentFlags().Lookup("sslmode"))
	viper.BindPFlag("cloudsql.enabled", rootCmd.PersistentFlags().Lookup("cloudsql"))
	viper.BindPFlag("cloudsql.project", rootCmd.PersistentFlags().Lookup("project"))
	viper.BindPFlag("cloudsql.region", rootCmd.PersistentFlags().Lookup("region"))
	viper.BindPFlag("cloudsql.instance", rootCmd.PersistentFlags().Lookup("instance"))
	viper.BindPFlag("cloudsql.private_ip", rootCmd.PersistentFlags().Lookup("private-ip"))

	// Add subcommands
	rootCmd.AddCommand(upCmd)
	rootCmd.AddCommand(downCmd)
	rootCmd.AddCommand(downAllCmd)
	rootCmd.AddCommand(versionCmd)
	rootCmd.AddCommand(forceCmd)
	rootCmd.AddCommand(createCmd)
}

func initConfig() {
	if cfgFile != "" {
		viper.SetConfigFile(cfgFile)
	} else {
		viper.AddConfigPath("./configs")
		viper.SetConfigName("config")
	}

	// Environment variables
	viper.SetEnvPrefix("DB")
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}
}

func getConfig() *database.Config {
	port := viper.GetInt("port")
	if dbType == "mysql" && port == 5432 {
		port = 3306
	}

	fmt.Printf("DEBUG: cloudsql.enabled = %v\n", viper.GetBool("cloudsql.enabled"))

	return &database.Config{
		Host:         viper.GetString("host"),
		Port:         port,
		User:         viper.GetString("user"),
		Password:     viper.GetString("password"),
		Database:     viper.GetString("database"),
		SSLMode:      viper.GetString("sslmode"),
		UseCloudSQL:  viper.GetBool("cloudsql.enabled"),
		ProjectID:    viper.GetString("cloudsql.project"),
		Region:       viper.GetString("cloudsql.region"),
		InstanceName: viper.GetString("cloudsql.instance"),
		UsePrivateIP: viper.GetBool("cloudsql.private_ip"),
	}
}

func getMigrationsPath() string {
	return filepath.Join("migrations", dbType)
}

func getDBType() database.DBType {
	if dbType == "mysql" {
		return database.DBTypeMySQL
	}
	return database.DBTypePostgres
}

func runMigration(action string) error {
	ctx := context.Background()
	cfg := getConfig()
	dbTypeEnum := getDBType()
	migrationsPath := getMigrationsPath()

	// Validate CloudSQL configuration (IAM auth required, no password)
	if err := cfg.ValidateCloudSQL(); err != nil {
		return err
	}

	var db interface{}
	var err error

	switch dbTypeEnum {
	case database.DBTypePostgres:
		db, err = database.ConnectPostgres(ctx, cfg)
	case database.DBTypeMySQL:
		db, err = database.ConnectMySQL(ctx, cfg)
	}

	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	sqlDB := db.(*sql.DB)

	migrator, err := database.NewMigrator(sqlDB, dbTypeEnum, migrationsPath)
	if err != nil {
		return fmt.Errorf("failed to create migrator: %w", err)
	}
	defer migrator.Close()

	switch action {
	case "up":
		fmt.Println("Running migrations...")
		if err := migrator.Up(); err != nil {
			return err
		}
		fmt.Println("Migrations completed successfully")

	case "down":
		fmt.Println("Rolling back last migration...")
		if err := migrator.Down(); err != nil {
			return err
		}
		fmt.Println("Rollback completed successfully")

	case "down-all":
		fmt.Println("Rolling back all migrations...")
		if err := migrator.DownAll(); err != nil {
			return err
		}
		fmt.Println("All migrations rolled back successfully")

	case "version":
		version, dirty, err := migrator.Version()
		if err != nil {
			return err
		}
		fmt.Printf("Current version: %d (dirty: %v)\n", version, dirty)

	case "force":
		// Force version would be handled differently
		fmt.Println("Force version not implemented in this example")
	}

	return nil
}

func createMigration(name string) error {
	migrationsPath := getMigrationsPath()

	// Create migrations directory if it doesn't exist
	if err := os.MkdirAll(migrationsPath, 0755); err != nil {
		return fmt.Errorf("failed to create migrations directory: %w", err)
	}

	// Generate timestamp-based version
	timestamp := fmt.Sprintf("%d", getNextVersion(migrationsPath))

	// Create up and down migration files
	upFile := filepath.Join(migrationsPath, fmt.Sprintf("%s_%s.up.sql", timestamp, name))
	downFile := filepath.Join(migrationsPath, fmt.Sprintf("%s_%s.down.sql", timestamp, name))

	upContent := fmt.Sprintf("-- Migration: %s\n-- Created at: %s\n\n-- Write your UP migration here\n", name, timestamp)
	downContent := fmt.Sprintf("-- Migration: %s\n-- Created at: %s\n\n-- Write your DOWN migration here\n", name, timestamp)

	if err := os.WriteFile(upFile, []byte(upContent), 0644); err != nil {
		return fmt.Errorf("failed to create up migration: %w", err)
	}

	if err := os.WriteFile(downFile, []byte(downContent), 0644); err != nil {
		return fmt.Errorf("failed to create down migration: %w", err)
	}

	fmt.Printf("Created migration files:\n  %s\n  %s\n", upFile, downFile)
	return nil
}

func getNextVersion(migrationsPath string) int64 {
	// Simple implementation - in production, use proper timestamp
	entries, _ := os.ReadDir(migrationsPath)
	return int64(len(entries)/2 + 1)
}

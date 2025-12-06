package database

import (
	"context"
	"database/sql"
	"fmt"
	"net"

	"cloud.google.com/go/cloudsqlconn"
	"cloud.google.com/go/cloudsqlconn/postgres/pgxv5"
	"github.com/go-sql-driver/mysql"
	_ "github.com/lib/pq"
)

// Config holds database connection configuration
type Config struct {
	// Common settings
	Host     string
	Port     int
	User     string
	Password string
	Database string
	SSLMode  string

	// CloudSQL specific
	UseCloudSQL  bool
	ProjectID    string
	Region       string
	InstanceName string
	UsePrivateIP bool
}

// ValidateCloudSQL validates CloudSQL configuration
// CloudSQL connections must use IAM authentication (no password)
func (c *Config) ValidateCloudSQL() error {
	if !c.UseCloudSQL {
		return nil
	}

	if c.Password != "" {
		return fmt.Errorf("CloudSQL connection requires IAM authentication; password must not be specified. Remove --password flag")
	}

	if c.ProjectID == "" {
		return fmt.Errorf("CloudSQL connection requires --project flag")
	}
	if c.Region == "" {
		return fmt.Errorf("CloudSQL connection requires --region flag")
	}
	if c.InstanceName == "" {
		return fmt.Errorf("CloudSQL connection requires --instance flag")
	}
	if c.User == "" {
		return fmt.Errorf("CloudSQL connection requires --user flag (IAM user email)")
	}

	return nil
}

// PostgresDSN returns a PostgreSQL connection string
func (c *Config) PostgresDSN() string {
	if c.UseCloudSQL {
		// CloudSQL connection string format
		return fmt.Sprintf(
			"host=%s user=%s password=%s dbname=%s sslmode=%s",
			c.CloudSQLInstanceConnectionName(),
			c.User,
			c.Password,
			c.Database,
			c.SSLMode,
		)
	}

	// Standard PostgreSQL connection string
	return fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		c.Host,
		c.Port,
		c.User,
		c.Password,
		c.Database,
		c.SSLMode,
	)
}

// MySQLDSN returns a MySQL connection string
func (c *Config) MySQLDSN() string {
	if c.UseCloudSQL {
		// CloudSQL uses custom dialer, DSN format is different
		return fmt.Sprintf(
			"%s:%s@cloudsql(%s)/%s?parseTime=true",
			c.User,
			c.Password,
			c.CloudSQLInstanceConnectionName(),
			c.Database,
		)
	}

	// Standard MySQL connection string
	return fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?parseTime=true",
		c.User,
		c.Password,
		c.Host,
		c.Port,
		c.Database,
	)
}

// CloudSQLInstanceConnectionName returns the full instance connection name
func (c *Config) CloudSQLInstanceConnectionName() string {
	return fmt.Sprintf("%s:%s:%s", c.ProjectID, c.Region, c.InstanceName)
}

// ConnectPostgres establishes a connection to PostgreSQL
func ConnectPostgres(ctx context.Context, cfg *Config) (*sql.DB, error) {
	if cfg.UseCloudSQL {
		return connectPostgresCloudSQL(ctx, cfg)
	}

	db, err := sql.Open("postgres", cfg.PostgresDSN())
	if err != nil {
		return nil, fmt.Errorf("failed to open postgres connection: %w", err)
	}

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping postgres: %w", err)
	}

	return db, nil
}

// connectPostgresCloudSQL connects to PostgreSQL via CloudSQL Connector with IAM authentication
func connectPostgresCloudSQL(ctx context.Context, cfg *Config) (*sql.DB, error) {
	instanceConnName := cfg.CloudSQLInstanceConnectionName()

	// Build DSN for pgx (no password - using IAM auth)
	dsn := fmt.Sprintf(
		"user=%s dbname=%s sslmode=disable host=%s",
		cfg.User,
		cfg.Database,
		instanceConnName,
	)

	// Use pgxv5 with CloudSQL connector and IAM authentication
	var opts []cloudsqlconn.Option
	opts = append(opts, cloudsqlconn.WithIAMAuthN()) // Enable IAM authentication

	if cfg.UsePrivateIP {
		opts = append(opts, cloudsqlconn.WithDefaultDialOptions(cloudsqlconn.WithPrivateIP()))
	}

	cleanup, err := pgxv5.RegisterDriver("cloudsql-postgres", opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to register cloudsql driver: %w", err)
	}
	_ = cleanup // Keep driver registered

	db, err := sql.Open("cloudsql-postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open postgres connection: %w", err)
	}

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping postgres: %w", err)
	}

	return db, nil
}

// ConnectMySQL establishes a connection to MySQL
func ConnectMySQL(ctx context.Context, cfg *Config) (*sql.DB, error) {
	if cfg.UseCloudSQL {
		return connectMySQLCloudSQL(ctx, cfg)
	}

	db, err := sql.Open("mysql", cfg.MySQLDSN())
	if err != nil {
		return nil, fmt.Errorf("failed to open mysql connection: %w", err)
	}

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping mysql: %w", err)
	}

	return db, nil
}

// connectMySQLCloudSQL connects to MySQL via CloudSQL Connector with IAM authentication
func connectMySQLCloudSQL(ctx context.Context, cfg *Config) (*sql.DB, error) {
	// Create dialer with IAM authentication
	dialer, err := cloudsqlconn.NewDialer(ctx, cloudsqlconn.WithIAMAuthN())
	if err != nil {
		return nil, fmt.Errorf("failed to create cloudsql dialer: %w", err)
	}

	instanceConnName := cfg.CloudSQLInstanceConnectionName()

	// Register the cloudsql driver for MySQL
	mysql.RegisterDialContext("cloudsql", func(ctx context.Context, addr string) (net.Conn, error) {
		opts := []cloudsqlconn.DialOption{}
		if cfg.UsePrivateIP {
			opts = append(opts, cloudsqlconn.WithPrivateIP())
		}
		return dialer.Dial(ctx, instanceConnName, opts...)
	})

	// DSN without password - IAM auth provides the token automatically
	dsn := fmt.Sprintf(
		"%s@cloudsql(%s)/%s?parseTime=true&allowCleartextPasswords=true",
		cfg.User,
		instanceConnName,
		cfg.Database,
	)

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open mysql connection: %w", err)
	}

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping mysql: %w", err)
	}

	return db, nil
}

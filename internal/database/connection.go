package database

import (
	"context"
	"database/sql"
	"fmt"
	"net"

	"cloud.google.com/go/cloudsqlconn"
	"github.com/go-sql-driver/mysql"
	"github.com/lib/pq"
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
	UseCloudSQL    bool
	ProjectID      string
	Region         string
	InstanceName   string
	UsePrivateIP   bool
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

// connectPostgresCloudSQL connects to PostgreSQL via CloudSQL Auth Proxy
func connectPostgresCloudSQL(ctx context.Context, cfg *Config) (*sql.DB, error) {
	dialer, err := cloudsqlconn.NewDialer(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to create cloudsql dialer: %w", err)
	}

	instanceConnName := cfg.CloudSQLInstanceConnectionName()

	// Register the cloudsql dialer
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s sslmode=disable",
		instanceConnName,
		cfg.User,
		cfg.Password,
		cfg.Database,
	)

	// Use pgx with cloudsql connector
	config, err := pq.ParseURL(fmt.Sprintf(
		"postgres://%s:%s@localhost/%s?sslmode=disable",
		cfg.User,
		cfg.Password,
		cfg.Database,
	))
	if err != nil {
		return nil, fmt.Errorf("failed to parse postgres url: %w", err)
	}

	_ = config // placeholder for custom dialer setup
	_ = dsn

	// For CloudSQL, we use the dialer directly
	db := sql.OpenDB(cloudsqlconn.NewPostgresDialer(dialer, instanceConnName, cfg.UsePrivateIP))

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

// connectMySQLCloudSQL connects to MySQL via CloudSQL Auth Proxy
func connectMySQLCloudSQL(ctx context.Context, cfg *Config) (*sql.DB, error) {
	dialer, err := cloudsqlconn.NewDialer(ctx)
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

	dsn := fmt.Sprintf(
		"%s:%s@cloudsql(%s)/%s?parseTime=true",
		cfg.User,
		cfg.Password,
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

// PostgresDialer is a custom connector for CloudSQL PostgreSQL
type PostgresDialer struct {
	dialer       *cloudsqlconn.Dialer
	instanceName string
	usePrivateIP bool
}

// NewPostgresDialer creates a new PostgreSQL dialer for CloudSQL
func NewPostgresDialer(dialer *cloudsqlconn.Dialer, instanceName string, usePrivateIP bool) *PostgresDialer {
	return &PostgresDialer{
		dialer:       dialer,
		instanceName: instanceName,
		usePrivateIP: usePrivateIP,
	}
}

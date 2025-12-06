package database

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database"
	"github.com/golang-migrate/migrate/v4/database/mysql"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// DBType represents the database type
type DBType string

const (
	DBTypePostgres DBType = "postgres"
	DBTypeMySQL    DBType = "mysql"
)

// Migrator handles database migrations
type Migrator struct {
	db       *sql.DB
	dbType   DBType
	migrate  *migrate.Migrate
	sourceURL string
}

// NewMigrator creates a new Migrator instance
func NewMigrator(db *sql.DB, dbType DBType, migrationsPath string) (*Migrator, error) {
	sourceURL := fmt.Sprintf("file://%s", migrationsPath)

	var driver database.Driver
	var err error

	switch dbType {
	case DBTypePostgres:
		driver, err = postgres.WithInstance(db, &postgres.Config{})
	case DBTypeMySQL:
		driver, err = mysql.WithInstance(db, &mysql.Config{})
	default:
		return nil, fmt.Errorf("unsupported database type: %s", dbType)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to create database driver: %w", err)
	}

	m, err := migrate.NewWithDatabaseInstance(sourceURL, string(dbType), driver)
	if err != nil {
		return nil, fmt.Errorf("failed to create migrate instance: %w", err)
	}

	return &Migrator{
		db:        db,
		dbType:    dbType,
		migrate:   m,
		sourceURL: sourceURL,
	}, nil
}

// Up runs all pending migrations
func (m *Migrator) Up() error {
	if err := m.migrate.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to run migrations: %w", err)
	}
	return nil
}

// Down rolls back the last migration
func (m *Migrator) Down() error {
	if err := m.migrate.Steps(-1); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to rollback migration: %w", err)
	}
	return nil
}

// DownAll rolls back all migrations
func (m *Migrator) DownAll() error {
	if err := m.migrate.Down(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to rollback all migrations: %w", err)
	}
	return nil
}

// Steps runs n migrations (positive = up, negative = down)
func (m *Migrator) Steps(n int) error {
	if err := m.migrate.Steps(n); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to run migration steps: %w", err)
	}
	return nil
}

// Version returns the current migration version
func (m *Migrator) Version() (uint, bool, error) {
	return m.migrate.Version()
}

// Force sets the migration version without running migrations
func (m *Migrator) Force(version int) error {
	return m.migrate.Force(version)
}

// Close closes the migrator
func (m *Migrator) Close() error {
	sourceErr, dbErr := m.migrate.Close()
	if sourceErr != nil {
		return fmt.Errorf("failed to close source: %w", sourceErr)
	}
	if dbErr != nil {
		return fmt.Errorf("failed to close database: %w", dbErr)
	}
	return nil
}

// RunMigrations is a convenience function to run migrations
func RunMigrations(ctx context.Context, cfg *Config, dbType DBType, migrationsPath string) error {
	var db *sql.DB
	var err error

	switch dbType {
	case DBTypePostgres:
		db, err = ConnectPostgres(ctx, cfg)
	case DBTypeMySQL:
		db, err = ConnectMySQL(ctx, cfg)
	default:
		return fmt.Errorf("unsupported database type: %s", dbType)
	}

	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer db.Close()

	migrator, err := NewMigrator(db, dbType, migrationsPath)
	if err != nil {
		return fmt.Errorf("failed to create migrator: %w", err)
	}
	defer migrator.Close()

	if err := migrator.Up(); err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	return nil
}

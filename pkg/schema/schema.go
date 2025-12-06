// Package schema provides embedded migration files for PostgreSQL and MySQL.
// This package can be imported by other repositories to share the same schema.
//
// Usage:
//
//	import "github.com/yourorg/cloudsql-migrate/pkg/schema"
//
//	fs, path := schema.GetPostgresFS()
//	source, err := iofs.New(fs, path)
package schema

import "embed"

//go:embed postgres/*.sql
var postgresFS embed.FS

//go:embed mysql/*.sql
var mysqlFS embed.FS

const (
	PostgresPath = "postgres"
	MySQLPath    = "mysql"
)

// GetPostgresFS returns the embedded filesystem and path for PostgreSQL migrations.
func GetPostgresFS() (embed.FS, string) {
	return postgresFS, PostgresPath
}

// GetMySQLFS returns the embedded filesystem and path for MySQL migrations.
func GetMySQLFS() (embed.FS, string) {
	return mysqlFS, MySQLPath
}

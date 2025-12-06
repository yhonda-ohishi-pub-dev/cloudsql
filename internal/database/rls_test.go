package database

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

// testConfig returns database configuration for testing
func testConfig() *Config {
	return &Config{
		Host:     getEnvOrDefault("TEST_DB_HOST", "localhost"),
		Port:     5432,
		User:     getEnvOrDefault("TEST_DB_USER", "postgres"),
		Password: getEnvOrDefault("TEST_DB_PASSWORD", "postgres"),
		Database: getEnvOrDefault("TEST_DB_NAME", "myapp_postgres"),
		SSLMode:  "disable",
	}
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// setupTestDB creates test data for RLS tests
func setupTestDB(t *testing.T, db *sql.DB) {
	t.Helper()

	// Clean up existing test data
	cleanupTestDB(t, db)

	// Create test organizations
	_, err := db.Exec(`
		INSERT INTO organizations (id, name, slug)
		VALUES
			('11111111-1111-1111-1111-111111111111', 'ACME Corp', 'acme'),
			('22222222-2222-2222-2222-222222222222', 'Globex Inc', 'globex')
		ON CONFLICT (id) DO NOTHING
	`)
	if err != nil {
		t.Fatalf("Failed to create test organizations: %v", err)
	}

	// Create test user
	_, err = db.Exec(`
		INSERT INTO app_users (id, iam_email, display_name, is_superadmin)
		VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'testuser@example.com', 'Test User', false)
		ON CONFLICT (id) DO NOTHING
	`)
	if err != nil {
		t.Fatalf("Failed to create test user: %v", err)
	}

	// Associate user with ACME
	_, err = db.Exec(`
		INSERT INTO user_organizations (user_id, organization_id, role, is_default)
		VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'admin', true)
		ON CONFLICT (user_id, organization_id) DO NOTHING
	`)
	if err != nil {
		t.Fatalf("Failed to associate user with organization: %v", err)
	}

	// Create test files
	_, err = db.Exec(`
		INSERT INTO files (uuid, organization_id, filename, created, type)
		VALUES
			('test-file-001', '11111111-1111-1111-1111-111111111111', 'acme_report.pdf', NOW()::TEXT, 'pdf'),
			('test-file-002', '22222222-2222-2222-2222-222222222222', 'globex_data.csv', NOW()::TEXT, 'csv')
		ON CONFLICT (uuid) DO NOTHING
	`)
	if err != nil {
		t.Fatalf("Failed to create test files: %v", err)
	}
}

// cleanupTestDB removes test data
func cleanupTestDB(t *testing.T, db *sql.DB) {
	t.Helper()

	// Delete test data in reverse order of creation
	db.Exec(`DELETE FROM files WHERE uuid IN ('test-file-001', 'test-file-002')`)
	db.Exec(`DELETE FROM user_organizations WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'`)
	db.Exec(`DELETE FROM app_users WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'`)
	db.Exec(`DELETE FROM organizations WHERE id IN ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222')`)
}

// createAppUserRole creates app_user role if not exists
func createAppUserRole(t *testing.T, db *sql.DB) {
	t.Helper()

	// Check if role exists
	var exists bool
	err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM pg_roles WHERE rolname = 'app_user')`).Scan(&exists)
	if err != nil {
		t.Fatalf("Failed to check role existence: %v", err)
	}

	if !exists {
		_, err = db.Exec(`CREATE ROLE app_user WITH LOGIN PASSWORD 'app_user_pass'`)
		if err != nil {
			t.Fatalf("Failed to create app_user role: %v", err)
		}
		_, err = db.Exec(`GRANT ALL ON ALL TABLES IN SCHEMA public TO app_user`)
		if err != nil {
			t.Fatalf("Failed to grant permissions: %v", err)
		}
		_, err = db.Exec(`GRANT USAGE ON SCHEMA public TO app_user`)
		if err != nil {
			t.Fatalf("Failed to grant schema usage: %v", err)
		}
	}
}

func TestRLS_NoSessionVariable(t *testing.T) {
	ctx := context.Background()
	cfg := testConfig()

	// Connect as postgres to setup test data
	adminDB, err := ConnectPostgres(ctx, cfg)
	if err != nil {
		t.Skipf("Database not available: %v", err)
	}
	defer adminDB.Close()

	setupTestDB(t, adminDB)
	createAppUserRole(t, adminDB)
	defer cleanupTestDB(t, adminDB)

	// Connect as app_user for RLS test
	appCfg := &Config{
		Host:     cfg.Host,
		Port:     cfg.Port,
		User:     "app_user",
		Password: "app_user_pass",
		Database: cfg.Database,
		SSLMode:  "disable",
	}

	appDB, err := ConnectPostgres(ctx, appCfg)
	if err != nil {
		t.Fatalf("Failed to connect as app_user: %v", err)
	}
	defer appDB.Close()

	// Query without session variable - should return 0 rows
	var count int
	err = appDB.QueryRow(`SELECT COUNT(*) FROM files WHERE uuid LIKE 'test-file-%'`).Scan(&count)
	if err != nil {
		t.Fatalf("Query failed: %v", err)
	}

	if count != 0 {
		t.Errorf("Expected 0 rows without session variable, got %d", count)
	}
}

func TestRLS_WithOrganizationSession(t *testing.T) {
	ctx := context.Background()
	cfg := testConfig()

	// Connect as postgres to setup test data
	adminDB, err := ConnectPostgres(ctx, cfg)
	if err != nil {
		t.Skipf("Database not available: %v", err)
	}
	defer adminDB.Close()

	setupTestDB(t, adminDB)
	createAppUserRole(t, adminDB)
	defer cleanupTestDB(t, adminDB)

	// Connect as app_user for RLS test
	appCfg := &Config{
		Host:     cfg.Host,
		Port:     cfg.Port,
		User:     "app_user",
		Password: "app_user_pass",
		Database: cfg.Database,
		SSLMode:  "disable",
	}

	appDB, err := ConnectPostgres(ctx, appCfg)
	if err != nil {
		t.Fatalf("Failed to connect as app_user: %v", err)
	}
	defer appDB.Close()

	testCases := []struct {
		name           string
		orgID          string
		expectedCount  int
		expectedFile   string
	}{
		{
			name:          "ACME Corp",
			orgID:         "11111111-1111-1111-1111-111111111111",
			expectedCount: 1,
			expectedFile:  "acme_report.pdf",
		},
		{
			name:          "Globex Inc",
			orgID:         "22222222-2222-2222-2222-222222222222",
			expectedCount: 1,
			expectedFile:  "globex_data.csv",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// Set organization session variable
			_, err := appDB.Exec(fmt.Sprintf(`SET app.current_organization_id = '%s'`, tc.orgID))
			if err != nil {
				t.Fatalf("Failed to set session variable: %v", err)
			}

			// Query files
			var count int
			err = appDB.QueryRow(`SELECT COUNT(*) FROM files WHERE uuid LIKE 'test-file-%'`).Scan(&count)
			if err != nil {
				t.Fatalf("Query failed: %v", err)
			}

			if count != tc.expectedCount {
				t.Errorf("Expected %d rows for %s, got %d", tc.expectedCount, tc.name, count)
			}

			// Verify filename
			var filename string
			err = appDB.QueryRow(`SELECT filename FROM files WHERE uuid LIKE 'test-file-%'`).Scan(&filename)
			if err != nil {
				t.Fatalf("Query failed: %v", err)
			}

			if filename != tc.expectedFile {
				t.Errorf("Expected filename %s, got %s", tc.expectedFile, filename)
			}

			// Reset session
			appDB.Exec(`RESET app.current_organization_id`)
		})
	}
}

func TestRLS_Superadmin(t *testing.T) {
	ctx := context.Background()
	cfg := testConfig()

	// Connect as postgres to setup test data
	adminDB, err := ConnectPostgres(ctx, cfg)
	if err != nil {
		t.Skipf("Database not available: %v", err)
	}
	defer adminDB.Close()

	setupTestDB(t, adminDB)
	createAppUserRole(t, adminDB)
	defer cleanupTestDB(t, adminDB)

	// Make test user superadmin
	_, err = adminDB.Exec(`UPDATE app_users SET is_superadmin = true WHERE iam_email = 'testuser@example.com'`)
	if err != nil {
		t.Fatalf("Failed to update user: %v", err)
	}

	// Connect as app_user for RLS test
	appCfg := &Config{
		Host:     cfg.Host,
		Port:     cfg.Port,
		User:     "app_user",
		Password: "app_user_pass",
		Database: cfg.Database,
		SSLMode:  "disable",
	}

	appDB, err := ConnectPostgres(ctx, appCfg)
	if err != nil {
		t.Fatalf("Failed to connect as app_user: %v", err)
	}
	defer appDB.Close()

	// Set superadmin session
	_, err = appDB.Exec(`SET app.current_user_email = 'testuser@example.com'`)
	if err != nil {
		t.Fatalf("Failed to set session variable: %v", err)
	}

	// Query files - superadmin should see all
	var count int
	err = appDB.QueryRow(`SELECT COUNT(*) FROM files WHERE uuid LIKE 'test-file-%'`).Scan(&count)
	if err != nil {
		t.Fatalf("Query failed: %v", err)
	}

	if count != 2 {
		t.Errorf("Superadmin expected 2 rows, got %d", count)
	}
}

func TestConnection_Postgres(t *testing.T) {
	ctx := context.Background()
	cfg := testConfig()

	db, err := ConnectPostgres(ctx, cfg)
	if err != nil {
		t.Skipf("Database not available: %v", err)
	}
	defer db.Close()

	// Test connection
	var result int
	err = db.QueryRow(`SELECT 1`).Scan(&result)
	if err != nil {
		t.Fatalf("Query failed: %v", err)
	}

	if result != 1 {
		t.Errorf("Expected 1, got %d", result)
	}
}

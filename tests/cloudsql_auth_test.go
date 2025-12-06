// CloudSQL Authentication Integration Tests
// Requires Cloud SQL Proxy running on port 5433
// Run: cloud-sql-proxy cloudsql-sv:asia-northeast1:postgres-prod --port=5433
// Then: go test -v ./tests/...

package tests

import (
	"database/sql"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

var (
	proxyHost    = getEnv("TEST_PROXY_HOST", "127.0.0.1")
	proxyPort    = getEnv("TEST_PROXY_PORT", "5433")
	testDatabase = getEnv("TEST_DATABASE", "myapp")
	iamUser      = getEnv("TEST_IAM_USER", "m.tama.ramu@gmail.com")
	pgPassword   = os.Getenv("TEST_POSTGRES_PASSWORD") // Required for postgres user tests
)

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func buildConnStr(user, password string) string {
	return "host=" + proxyHost + " port=" + proxyPort + " user=" + user + " password=" + password + " dbname=" + testDatabase + " sslmode=disable"
}

// TestIAMUserPasswordRejection verifies that IAM users cannot authenticate with passwords
func TestIAMUserPasswordRejection(t *testing.T) {
	connStr := buildConnStr(iamUser, "fake_password")

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		t.Logf("sql.Open failed (acceptable): %v", err)
		return
	}
	defer db.Close()

	err = db.Ping()
	if err == nil {
		t.Error("IAM user should not be able to authenticate with password")
	} else {
		t.Logf("IAM user password rejected as expected: %v", err)
	}
}

// TestPostgresUserCorrectPassword verifies that postgres user can authenticate with correct password
func TestPostgresUserCorrectPassword(t *testing.T) {
	if pgPassword == "" {
		t.Skip("TEST_POSTGRES_PASSWORD not set")
	}

	connStr := buildConnStr("postgres", pgPassword)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		t.Fatalf("sql.Open failed: %v", err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		t.Errorf("postgres user should be able to authenticate with correct password: %v", err)
	}
}

// TestPostgresUserWrongPassword verifies that postgres user cannot authenticate with wrong password
func TestPostgresUserWrongPassword(t *testing.T) {
	connStr := buildConnStr("postgres", "wrong_password")

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		t.Logf("sql.Open failed (acceptable): %v", err)
		return
	}
	defer db.Close()

	err = db.Ping()
	if err == nil {
		t.Error("postgres user should not be able to authenticate with wrong password")
	} else {
		t.Logf("postgres user wrong password rejected as expected: %v", err)
	}
}

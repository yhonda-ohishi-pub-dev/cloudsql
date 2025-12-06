.PHONY: build run test clean help
.PHONY: migrate-up migrate-down migrate-version migrate-create
.PHONY: pg-up pg-down pg-version mysql-up mysql-down mysql-version
.PHONY: docker-up docker-down docker-reset
.PHONY: cloudsql-pg-stop cloudsql-pg-start cloudsql-mysql-stop cloudsql-mysql-start
.PHONY: test-rls test-integration test-all test-cloudsql-auth
.PHONY: proxy-start proxy-stop

# Build settings
BINARY_NAME=migrate
BUILD_DIR=./bin

# Default database type
DB_TYPE?=postgres

# Build the migration tool
build:
	go build -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/migrate

# Run migrations
run: build
	$(BUILD_DIR)/$(BINARY_NAME)

# Test
test:
	go test -v ./...

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	go clean

# Install dependencies
deps:
	go mod download
	go mod tidy

#
# Migration commands
#

# Generic migration commands (use DB_TYPE env var)
migrate-up: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=$(DB_TYPE) up

migrate-down: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=$(DB_TYPE) down

migrate-down-all: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=$(DB_TYPE) down-all

migrate-version: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=$(DB_TYPE) version

migrate-create: build
	@read -p "Migration name: " name; \
	$(BUILD_DIR)/$(BINARY_NAME) --db=$(DB_TYPE) create $$name

#
# PostgreSQL specific commands
#

pg-up: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=postgres --config=./configs/config.postgres.yaml up

pg-down: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=postgres --config=./configs/config.postgres.yaml down

pg-version: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=postgres --config=./configs/config.postgres.yaml version

pg-create: build
	@read -p "Migration name: " name; \
	$(BUILD_DIR)/$(BINARY_NAME) --db=postgres create $$name

#
# MySQL specific commands
#

mysql-up: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=mysql --config=./configs/config.mysql.yaml up

mysql-down: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=mysql --config=./configs/config.mysql.yaml down

mysql-version: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=mysql --config=./configs/config.mysql.yaml version

mysql-create: build
	@read -p "Migration name: " name; \
	$(BUILD_DIR)/$(BINARY_NAME) --db=mysql create $$name

#
# Docker commands
#

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

docker-reset:
	docker-compose down -v
	docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 10

#
# Test commands
#

# Run all tests
test-all: test-rls
	go test -v ./...

# Run RLS integration tests (requires Docker database)
test-rls:
	@echo "Running RLS integration tests..."
	go test -v -run TestRLS ./internal/database/...

# Run integration tests with fresh database
test-integration: docker-reset pg-up test-rls
	@echo "Integration tests completed"

# Run CloudSQL authentication tests (requires proxy running on port 5433)
# Usage: make test-cloudsql-auth TEST_POSTGRES_PASSWORD=<password>
test-cloudsql-auth:
	@echo "Running CloudSQL authentication tests..."
	@echo "Note: Requires Cloud SQL Proxy running on port 5433"
	go test -v ./tests/...

#
# CloudSQL commands (requires gcloud auth)
#

cloudsql-pg-up: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=postgres --cloudsql \
		--project=$(GCP_PROJECT) \
		--region=$(GCP_REGION) \
		--instance=$(PG_INSTANCE) \
		--user=$(DB_USER) \
		--password=$(DB_PASSWORD) \
		--database=$(DB_NAME) up

cloudsql-mysql-up: build
	$(BUILD_DIR)/$(BINARY_NAME) --db=mysql --cloudsql \
		--project=$(GCP_PROJECT) \
		--region=$(GCP_REGION) \
		--instance=$(MYSQL_INSTANCE) \
		--user=$(DB_USER) \
		--password=$(DB_PASSWORD) \
		--database=$(DB_NAME) up

#
# CloudSQL instance start/stop commands
#

cloudsql-pg-stop:
	gcloud sql instances patch $(PG_INSTANCE) --activation-policy=NEVER --project=$(GCP_PROJECT)

cloudsql-pg-start:
	gcloud sql instances patch $(PG_INSTANCE) --activation-policy=ALWAYS --project=$(GCP_PROJECT)

cloudsql-mysql-stop:
	gcloud sql instances patch $(MYSQL_INSTANCE) --activation-policy=NEVER --project=$(GCP_PROJECT)

cloudsql-mysql-start:
	gcloud sql instances patch $(MYSQL_INSTANCE) --activation-policy=ALWAYS --project=$(GCP_PROJECT)

#
# Cloud SQL Proxy commands
#

# Start Cloud SQL Proxy for postgres-prod (port 5433)
proxy-start:
	@echo "Starting Cloud SQL Proxy on port 5433..."
	./cloud-sql-proxy.exe cloudsql-sv:asia-northeast1:postgres-prod --port=5433 &

# Stop Cloud SQL Proxy
proxy-stop:
	@echo "Stopping Cloud SQL Proxy..."
	-taskkill /IM cloud-sql-proxy.exe /F 2>/dev/null || pkill -f cloud-sql-proxy || true

# Help
help:
	@echo "CloudSQL Migration Tool"
	@echo ""
	@echo "Usage:"
	@echo "  make build          - Build the migration tool"
	@echo "  make deps           - Install dependencies"
	@echo "  make test           - Run unit tests"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Local Development:"
	@echo "  make docker-up      - Start local PostgreSQL and MySQL"
	@echo "  make docker-down    - Stop local databases"
	@echo "  make docker-reset   - Reset databases (delete volumes)"
	@echo ""
	@echo "Testing:"
	@echo "  make test-rls       - Run RLS integration tests"
	@echo "  make test-integration - Full integration test (reset + migrate + test)"
	@echo "  make test-all       - Run all tests"
	@echo ""
	@echo "PostgreSQL Migrations:"
	@echo "  make pg-up          - Run PostgreSQL migrations"
	@echo "  make pg-down        - Rollback last PostgreSQL migration"
	@echo "  make pg-version     - Show PostgreSQL migration version"
	@echo "  make pg-create      - Create new PostgreSQL migration"
	@echo ""
	@echo "MySQL Migrations:"
	@echo "  make mysql-up       - Run MySQL migrations"
	@echo "  make mysql-down     - Rollback last MySQL migration"
	@echo "  make mysql-version  - Show MySQL migration version"
	@echo "  make mysql-create   - Create new MySQL migration"
	@echo ""
	@echo "CloudSQL (set GCP_PROJECT, GCP_REGION, etc.):"
	@echo "  make cloudsql-pg-up      - Run migrations on CloudSQL PostgreSQL"
	@echo "  make cloudsql-mysql-up   - Run migrations on CloudSQL MySQL"
	@echo ""
	@echo "CloudSQL Instance Control:"
	@echo "  make cloudsql-pg-stop    - Stop CloudSQL PostgreSQL instance"
	@echo "  make cloudsql-pg-start   - Start CloudSQL PostgreSQL instance"
	@echo "  make cloudsql-mysql-stop - Stop CloudSQL MySQL instance"
	@echo "  make cloudsql-mysql-start- Start CloudSQL MySQL instance"
	@echo ""
	@echo "Cloud SQL Proxy:"
	@echo "  make proxy-start         - Start Cloud SQL Proxy (port 5433)"
	@echo "  make proxy-stop          - Stop Cloud SQL Proxy"
	@echo ""
	@echo "CloudSQL Auth Tests:"
	@echo "  make test-cloudsql-auth  - Run authentication tests (requires proxy)"

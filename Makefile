.PHONY: build run test clean help
.PHONY: migrate-up migrate-down migrate-version migrate-create
.PHONY: pg-up pg-down pg-version mysql-up mysql-down mysql-version
.PHONY: docker-up docker-down

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

# Help
help:
	@echo "CloudSQL Migration Tool"
	@echo ""
	@echo "Usage:"
	@echo "  make build          - Build the migration tool"
	@echo "  make deps           - Install dependencies"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Local Development:"
	@echo "  make docker-up      - Start local PostgreSQL and MySQL"
	@echo "  make docker-down    - Stop local databases"
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
	@echo "  make cloudsql-pg-up    - Run migrations on CloudSQL PostgreSQL"
	@echo "  make cloudsql-mysql-up - Run migrations on CloudSQL MySQL"

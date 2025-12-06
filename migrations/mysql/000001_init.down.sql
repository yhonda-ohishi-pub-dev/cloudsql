-- Migration: init (rollback)
-- Database: MySQL

DROP INDEX idx_users_email ON users;
DROP TABLE IF EXISTS users;

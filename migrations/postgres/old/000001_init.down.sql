-- Migration: init (rollback)
-- Database: PostgreSQL

DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;

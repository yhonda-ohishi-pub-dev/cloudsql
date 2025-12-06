-- Migration: app_users (ROLLBACK)
-- Database: PostgreSQL

DROP FUNCTION IF EXISTS is_superadmin();
DROP FUNCTION IF EXISTS current_user_default_organization_id();
DROP FUNCTION IF EXISTS current_user_organizations();
DROP INDEX IF EXISTS idx_user_organizations_is_default;
DROP INDEX IF EXISTS idx_user_organizations_organization_id;
DROP INDEX IF EXISTS idx_user_organizations_user_id;
DROP TABLE IF EXISTS public.user_organizations;
DROP INDEX IF EXISTS idx_app_users_deleted_at;
DROP INDEX IF EXISTS idx_app_users_iam_email;
DROP TABLE IF EXISTS public.app_users;

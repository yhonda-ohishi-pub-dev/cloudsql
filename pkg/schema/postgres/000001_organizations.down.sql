-- Migration: organizations (ROLLBACK)
-- Database: PostgreSQL

DROP FUNCTION IF EXISTS current_organization_id();
DROP INDEX IF EXISTS idx_organizations_deleted_at;
DROP INDEX IF EXISTS idx_organizations_slug;
DROP TABLE IF EXISTS public.organizations;

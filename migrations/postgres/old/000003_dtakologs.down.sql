-- Migration: dtakologs (ROLLBACK)
-- Database: PostgreSQL
-- Description: Drop dtakologs table

DROP INDEX IF EXISTS idx_dtakologs_branch_cd;
DROP INDEX IF EXISTS idx_dtakologs_driver_cd;
DROP INDEX IF EXISTS idx_dtakologs_vehicle_cd;

DROP TABLE IF EXISTS public.dtakologs;

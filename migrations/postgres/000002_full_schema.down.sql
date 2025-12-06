-- Migration: full_schema (ROLLBACK)
-- Database: PostgreSQL
-- Description: Drop all tables from db202512051200 schema

-- ============================================================================
-- DROP INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_uriage_date;
DROP INDEX IF EXISTS idx_cam_files_date;
DROP INDEX IF EXISTS idx_ichiban_cars_id4;
DROP INDEX IF EXISTS idx_car_inspection_files_elect_cert;
DROP INDEX IF EXISTS idx_car_inspection_car_id;
DROP INDEX IF EXISTS idx_kudgsir_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgivt_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgful_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgfry_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgcst_kudguri_uuid;

-- ============================================================================
-- DROP FOREIGN KEY CONSTRAINTS
-- ============================================================================
ALTER TABLE IF EXISTS public.car_inspection_deregistration_files
    DROP CONSTRAINT IF EXISTS fk_car_inspection_deregistration_files_files;

ALTER TABLE IF EXISTS public.kudgsir
    DROP CONSTRAINT IF EXISTS fk_kudgsir_kudguri;

ALTER TABLE IF EXISTS public.kudgivt
    DROP CONSTRAINT IF EXISTS fk_kudgivt_kudguri;

ALTER TABLE IF EXISTS public.kudgful
    DROP CONSTRAINT IF EXISTS fk_kudgful_kudguri;

ALTER TABLE IF EXISTS public.kudgfry
    DROP CONSTRAINT IF EXISTS fk_kudgfry_kudguri;

ALTER TABLE IF EXISTS public.kudgcst
    DROP CONSTRAINT IF EXISTS fk_kudgcst_kudguri;

-- ============================================================================
-- DROP TABLES (reverse order of creation for FK dependencies)
-- ============================================================================
-- Sales tables
DROP TABLE IF EXISTS public.uriage_jisha;
DROP TABLE IF EXISTS public.uriage;

-- KUDGURI child tables
DROP TABLE IF EXISTS public.kudgsir;
DROP TABLE IF EXISTS public.kudgivt;
DROP TABLE IF EXISTS public.kudgful;
DROP TABLE IF EXISTS public.kudgfry;
DROP TABLE IF EXISTS public.kudgcst;
-- KUDGURI parent table
DROP TABLE IF EXISTS public.kudguri;

-- Car registry tables
DROP TABLE IF EXISTS public.dtako_cars_ichiban_cars;
DROP TABLE IF EXISTS public.ichiban_cars;

-- Car inspection tables
DROP TABLE IF EXISTS public.car_ins_sheet_ichiban_cars_a;
DROP TABLE IF EXISTS public.car_ins_sheet_ichiban_cars;
DROP TABLE IF EXISTS public.car_inspection_deregistration_files;
DROP TABLE IF EXISTS public.car_inspection_deregistration;
DROP TABLE IF EXISTS public.car_inspection_files_b;
DROP TABLE IF EXISTS public.car_inspection_files_a;
DROP TABLE IF EXISTS public.car_inspection_files;
DROP TABLE IF EXISTS public.car_inspection;

-- Camera files tables
DROP TABLE IF EXISTS public.cam_files;
DROP TABLE IF EXISTS public.cam_file_exe;
DROP TABLE IF EXISTS public.cam_file_exe_stage;

-- Core tables
DROP TABLE IF EXISTS public.flickr_photo;
DROP TABLE IF EXISTS public.files;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS my_schema.users;
DROP TABLE IF EXISTS drizzle.__drizzle_migrations;

-- ============================================================================
-- DROP TYPES
-- ============================================================================
DROP TYPE IF EXISTS my_schema.colors;

-- ============================================================================
-- DROP SCHEMAS
-- ============================================================================
DROP SCHEMA IF EXISTS my_schema;
DROP SCHEMA IF EXISTS drizzle;

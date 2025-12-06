-- Migration: base_tables (ROLLBACK)
-- Database: PostgreSQL

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
-- DROP INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_dtakologs_branch_cd;
DROP INDEX IF EXISTS idx_dtakologs_driver_cd;
DROP INDEX IF EXISTS idx_dtakologs_vehicle_cd;
DROP INDEX IF EXISTS idx_dtakologs_organization_id;
DROP INDEX IF EXISTS idx_uriage_jisha_organization_id;
DROP INDEX IF EXISTS idx_uriage_date;
DROP INDEX IF EXISTS idx_uriage_organization_id;
DROP INDEX IF EXISTS idx_kudgsir_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgsir_organization_id;
DROP INDEX IF EXISTS idx_kudgivt_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgivt_organization_id;
DROP INDEX IF EXISTS idx_kudgful_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgful_organization_id;
DROP INDEX IF EXISTS idx_kudgfry_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgfry_organization_id;
DROP INDEX IF EXISTS idx_kudgcst_kudguri_uuid;
DROP INDEX IF EXISTS idx_kudgcst_organization_id;
DROP INDEX IF EXISTS idx_kudguri_organization_id;
DROP INDEX IF EXISTS idx_dtako_cars_ichiban_cars_organization_id;
DROP INDEX IF EXISTS idx_ichiban_cars_id4;
DROP INDEX IF EXISTS idx_ichiban_cars_organization_id;
DROP INDEX IF EXISTS idx_car_ins_sheet_ichiban_cars_a_organization_id;
DROP INDEX IF EXISTS idx_car_ins_sheet_ichiban_cars_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_deregistration_files_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_deregistration_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_files_b_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_files_a_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_files_elect_cert;
DROP INDEX IF EXISTS idx_car_inspection_files_organization_id;
DROP INDEX IF EXISTS idx_car_inspection_car_id;
DROP INDEX IF EXISTS idx_car_inspection_organization_id;
DROP INDEX IF EXISTS idx_cam_files_date;
DROP INDEX IF EXISTS idx_cam_files_organization_id;
DROP INDEX IF EXISTS idx_cam_file_exe_organization_id;
DROP INDEX IF EXISTS idx_cam_file_exe_stage_organization_id;
DROP INDEX IF EXISTS idx_flickr_photo_organization_id;
DROP INDEX IF EXISTS idx_files_organization_id;

-- ============================================================================
-- DROP TABLES (reverse order)
-- ============================================================================
DROP TABLE IF EXISTS public.dtakologs;
DROP TABLE IF EXISTS public.uriage_jisha;
DROP TABLE IF EXISTS public.uriage;
DROP TABLE IF EXISTS public.kudgsir;
DROP TABLE IF EXISTS public.kudgivt;
DROP TABLE IF EXISTS public.kudgful;
DROP TABLE IF EXISTS public.kudgfry;
DROP TABLE IF EXISTS public.kudgcst;
DROP TABLE IF EXISTS public.kudguri;
DROP TABLE IF EXISTS public.dtako_cars_ichiban_cars;
DROP TABLE IF EXISTS public.ichiban_cars;
DROP TABLE IF EXISTS public.car_ins_sheet_ichiban_cars_a;
DROP TABLE IF EXISTS public.car_ins_sheet_ichiban_cars;
DROP TABLE IF EXISTS public.car_inspection_deregistration_files;
DROP TABLE IF EXISTS public.car_inspection_deregistration;
DROP TABLE IF EXISTS public.car_inspection_files_b;
DROP TABLE IF EXISTS public.car_inspection_files_a;
DROP TABLE IF EXISTS public.car_inspection_files;
DROP TABLE IF EXISTS public.car_inspection;
DROP TABLE IF EXISTS public.cam_files;
DROP TABLE IF EXISTS public.cam_file_exe;
DROP TABLE IF EXISTS public.cam_file_exe_stage;
DROP TABLE IF EXISTS public.flickr_photo;
DROP TABLE IF EXISTS public.files;

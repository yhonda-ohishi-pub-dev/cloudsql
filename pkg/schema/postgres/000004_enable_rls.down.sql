-- Migration: enable_rls (ROLLBACK)
-- Database: PostgreSQL

-- ============================================================================
-- DROP RLS POLICIES
-- ============================================================================

-- Helper function to drop all tenant policies for a table
CREATE OR REPLACE FUNCTION drop_tenant_policies(table_name TEXT)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_select ON public.%I', table_name, table_name);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_insert ON public.%I', table_name, table_name);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_update ON public.%I', table_name, table_name);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_delete ON public.%I', table_name, table_name);
END;
$$ LANGUAGE plpgsql;

-- Drop policies from all tables
SELECT drop_tenant_policies('dtakologs');
SELECT drop_tenant_policies('uriage_jisha');
SELECT drop_tenant_policies('uriage');
SELECT drop_tenant_policies('kudgsir');
SELECT drop_tenant_policies('kudgivt');
SELECT drop_tenant_policies('kudgful');
SELECT drop_tenant_policies('kudgfry');
SELECT drop_tenant_policies('kudgcst');
SELECT drop_tenant_policies('kudguri');
SELECT drop_tenant_policies('dtako_cars_ichiban_cars');
SELECT drop_tenant_policies('ichiban_cars');
SELECT drop_tenant_policies('car_ins_sheet_ichiban_cars_a');
SELECT drop_tenant_policies('car_ins_sheet_ichiban_cars');
SELECT drop_tenant_policies('car_inspection_deregistration_files');
SELECT drop_tenant_policies('car_inspection_deregistration');
SELECT drop_tenant_policies('car_inspection_files_b');
SELECT drop_tenant_policies('car_inspection_files_a');
SELECT drop_tenant_policies('car_inspection_files');
SELECT drop_tenant_policies('car_inspection');
SELECT drop_tenant_policies('cam_files');
SELECT drop_tenant_policies('cam_file_exe');
SELECT drop_tenant_policies('cam_file_exe_stage');
SELECT drop_tenant_policies('flickr_photo');
SELECT drop_tenant_policies('files');

DROP FUNCTION IF EXISTS drop_tenant_policies(TEXT);
DROP FUNCTION IF EXISTS create_tenant_policies(TEXT);

-- ============================================================================
-- DISABLE RLS
-- ============================================================================

-- Dtakologs
ALTER TABLE public.dtakologs DISABLE ROW LEVEL SECURITY;

-- Sales
ALTER TABLE public.uriage_jisha DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.uriage DISABLE ROW LEVEL SECURITY;

-- Kudguri
ALTER TABLE public.kudgsir DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgivt DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgful DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgfry DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgcst DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudguri DISABLE ROW LEVEL SECURITY;

-- Car Registry
ALTER TABLE public.dtako_cars_ichiban_cars DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ichiban_cars DISABLE ROW LEVEL SECURITY;

-- Car Inspection
ALTER TABLE public.car_ins_sheet_ichiban_cars_a DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_ins_sheet_ichiban_cars DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration_files DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_b DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_a DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection DISABLE ROW LEVEL SECURITY;

-- Camera Files
ALTER TABLE public.cam_files DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cam_file_exe DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cam_file_exe_stage DISABLE ROW LEVEL SECURITY;

-- Flickr Photo
ALTER TABLE public.flickr_photo DISABLE ROW LEVEL SECURITY;

-- Files
ALTER TABLE public.files DISABLE ROW LEVEL SECURITY;

-- Migration: enable_rls
-- Database: PostgreSQL
-- Description: Row Level Security (RLS) 有効化 + ポリシー作成

-- ============================================================================
-- RLS有効化: 全ビジネステーブル
-- ============================================================================

-- Files
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files FORCE ROW LEVEL SECURITY;

-- Flickr Photo
ALTER TABLE public.flickr_photo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flickr_photo FORCE ROW LEVEL SECURITY;

-- Camera Files
ALTER TABLE public.cam_file_exe_stage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cam_file_exe_stage FORCE ROW LEVEL SECURITY;
ALTER TABLE public.cam_file_exe ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cam_file_exe FORCE ROW LEVEL SECURITY;
ALTER TABLE public.cam_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cam_files FORCE ROW LEVEL SECURITY;

-- Car Inspection
ALTER TABLE public.car_inspection ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_a ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_a FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_b ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_files_b FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_inspection_deregistration_files FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_ins_sheet_ichiban_cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_ins_sheet_ichiban_cars FORCE ROW LEVEL SECURITY;
ALTER TABLE public.car_ins_sheet_ichiban_cars_a ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_ins_sheet_ichiban_cars_a FORCE ROW LEVEL SECURITY;

-- Car Registry
ALTER TABLE public.ichiban_cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ichiban_cars FORCE ROW LEVEL SECURITY;
ALTER TABLE public.dtako_cars_ichiban_cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dtako_cars_ichiban_cars FORCE ROW LEVEL SECURITY;

-- Kudguri (Vehicle Tracking)
ALTER TABLE public.kudguri ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudguri FORCE ROW LEVEL SECURITY;
ALTER TABLE public.kudgcst ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgcst FORCE ROW LEVEL SECURITY;
ALTER TABLE public.kudgfry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgfry FORCE ROW LEVEL SECURITY;
ALTER TABLE public.kudgful ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgful FORCE ROW LEVEL SECURITY;
ALTER TABLE public.kudgivt ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgivt FORCE ROW LEVEL SECURITY;
ALTER TABLE public.kudgsir ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kudgsir FORCE ROW LEVEL SECURITY;

-- Sales
ALTER TABLE public.uriage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.uriage FORCE ROW LEVEL SECURITY;
ALTER TABLE public.uriage_jisha ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.uriage_jisha FORCE ROW LEVEL SECURITY;

-- Dtakologs
ALTER TABLE public.dtakologs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dtakologs FORCE ROW LEVEL SECURITY;

-- ============================================================================
-- RLSポリシー作成: テナント分離
-- organization_id = current_organization_id() または superadmin
-- ============================================================================

-- マクロ的にポリシーを作成する関数
-- 使用法: SELECT create_tenant_policy('table_name');

CREATE OR REPLACE FUNCTION create_tenant_policies(table_name TEXT)
RETURNS VOID AS $$
BEGIN
    -- SELECT ポリシー
    EXECUTE format(
        'CREATE POLICY %I_tenant_select ON public.%I FOR SELECT
         USING (organization_id = current_organization_id() OR is_superadmin())',
        table_name, table_name
    );

    -- INSERT ポリシー
    EXECUTE format(
        'CREATE POLICY %I_tenant_insert ON public.%I FOR INSERT
         WITH CHECK (organization_id = current_organization_id() OR is_superadmin())',
        table_name, table_name
    );

    -- UPDATE ポリシー
    EXECUTE format(
        'CREATE POLICY %I_tenant_update ON public.%I FOR UPDATE
         USING (organization_id = current_organization_id() OR is_superadmin())
         WITH CHECK (organization_id = current_organization_id() OR is_superadmin())',
        table_name, table_name
    );

    -- DELETE ポリシー
    EXECUTE format(
        'CREATE POLICY %I_tenant_delete ON public.%I FOR DELETE
         USING (organization_id = current_organization_id() OR is_superadmin())',
        table_name, table_name
    );
END;
$$ LANGUAGE plpgsql;

-- 全テーブルにポリシー適用
SELECT create_tenant_policies('files');
SELECT create_tenant_policies('flickr_photo');
SELECT create_tenant_policies('cam_file_exe_stage');
SELECT create_tenant_policies('cam_file_exe');
SELECT create_tenant_policies('cam_files');
SELECT create_tenant_policies('car_inspection');
SELECT create_tenant_policies('car_inspection_files');
SELECT create_tenant_policies('car_inspection_files_a');
SELECT create_tenant_policies('car_inspection_files_b');
SELECT create_tenant_policies('car_inspection_deregistration');
SELECT create_tenant_policies('car_inspection_deregistration_files');
SELECT create_tenant_policies('car_ins_sheet_ichiban_cars');
SELECT create_tenant_policies('car_ins_sheet_ichiban_cars_a');
SELECT create_tenant_policies('ichiban_cars');
SELECT create_tenant_policies('dtako_cars_ichiban_cars');
SELECT create_tenant_policies('kudguri');
SELECT create_tenant_policies('kudgcst');
SELECT create_tenant_policies('kudgfry');
SELECT create_tenant_policies('kudgful');
SELECT create_tenant_policies('kudgivt');
SELECT create_tenant_policies('kudgsir');
SELECT create_tenant_policies('uriage');
SELECT create_tenant_policies('uriage_jisha');
SELECT create_tenant_policies('dtakologs');

-- ヘルパー関数は残す（他で使用可能）
-- DROP FUNCTION IF EXISTS create_tenant_policies(TEXT);

COMMENT ON FUNCTION create_tenant_policies(TEXT) IS 'テーブルにテナント分離用のRLSポリシーを作成';

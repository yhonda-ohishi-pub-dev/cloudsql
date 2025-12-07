-- Migration: iam_user_grants (ROLLBACK)
-- Database: PostgreSQL
-- Description: Cloud SQL IAMユーザーへのテーブルアクセス権限取り消し

-- ============================================================================
-- 権限取り消し
-- ============================================================================

-- 認証系テーブル
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.app_users FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.oauth_accounts FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.organizations FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.user_organizations FROM cloudsqliamuser;

-- ビジネステーブル
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.files FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.flickr_photo FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe_stage FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_files FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_a FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_b FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration_files FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars_a FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.ichiban_cars FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.dtako_cars_ichiban_cars FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudguri FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgcst FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgfry FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgful FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgivt FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgsir FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.uriage FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.uriage_jisha FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.dtakologs FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.schema_migrations FROM cloudsqliamuser;

-- シーケンス
REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public FROM cloudsqliamuser;

-- デフォルト権限も取り消し
ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM cloudsqliamuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE USAGE, SELECT ON SEQUENCES FROM cloudsqliamuser;

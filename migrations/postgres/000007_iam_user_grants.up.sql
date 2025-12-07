-- Migration: iam_user_grants
-- Database: PostgreSQL
-- Description: Cloud SQL IAMユーザーへのテーブルアクセス権限付与

-- ============================================================================
-- IAMユーザー権限付与
-- Cloud SQLのIAM認証では、IAMユーザーは自動的にcloudsqliamuser権限を持つが
-- 個別テーブルへのアクセス権限は別途付与が必要
-- ============================================================================

-- 現在のスキーマのデフォルト権限を設定（将来作成されるテーブルにも適用）
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cloudsqliamuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO cloudsqliamuser;

-- ============================================================================
-- 既存テーブルへの権限付与
-- ============================================================================

-- 認証系テーブル（RLSなし、全アクセス許可）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_users TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.oauth_accounts TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.organizations TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_organizations TO cloudsqliamuser;

-- ビジネステーブル（RLSで保護、アクセスはポリシーで制御）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.files TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.flickr_photo TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe_stage TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_files TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_a TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_b TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration_files TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars_a TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ichiban_cars TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dtako_cars_ichiban_cars TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudguri TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgcst TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgfry TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgful TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgivt TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgsir TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.uriage TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.uriage_jisha TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dtakologs TO cloudsqliamuser;

-- schema_migrations テーブル（マイグレーションツール用）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.schema_migrations TO cloudsqliamuser;

-- シーケンスへの権限付与
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO cloudsqliamuser;

COMMENT ON FUNCTION current_organization_id() IS 'RLSポリシーで使用する現在のorganization_id取得関数';
COMMENT ON FUNCTION current_user_organizations() IS 'RLSポリシーで使用する現在ユーザーの所属organization_id一覧取得関数';
COMMENT ON FUNCTION is_superadmin() IS 'RLSポリシーで使用するsuperadminチェック関数';

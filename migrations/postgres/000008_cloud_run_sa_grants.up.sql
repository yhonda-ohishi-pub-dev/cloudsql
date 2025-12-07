-- Migration: cloud_run_sa_grants
-- Database: PostgreSQL
-- Description: Cloud Runサービスアカウントへのテーブルアクセス権限付与

-- ============================================================================
-- Cloud Run サービスアカウント権限付与
-- 747065218280-compute@developer はCloud SQLのIAM認証で自動作成されるロール
-- cloudsqliamuserのメンバーではないため、直接権限付与が必要
-- ============================================================================

-- 認証系テーブル（RLSなし）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_users TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.oauth_accounts TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.organizations TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_organizations TO "747065218280-compute@developer";

-- ビジネステーブル（RLSで保護）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.files TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.flickr_photo TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe_stage TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cam_files TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_a TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_b TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration_files TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars_a TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ichiban_cars TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dtako_cars_ichiban_cars TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudguri TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgcst TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgfry TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgful TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgivt TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kudgsir TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.uriage TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.uriage_jisha TO "747065218280-compute@developer";
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dtakologs TO "747065218280-compute@developer";

-- シーケンスへの権限付与
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "747065218280-compute@developer";

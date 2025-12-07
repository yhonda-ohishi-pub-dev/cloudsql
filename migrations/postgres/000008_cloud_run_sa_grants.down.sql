-- Migration: cloud_run_sa_grants (ROLLBACK)
-- Database: PostgreSQL

-- 認証系テーブル
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.app_users FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.oauth_accounts FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.organizations FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.user_organizations FROM "747065218280-compute@developer";

-- ビジネステーブル
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.files FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.flickr_photo FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe_stage FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_file_exe FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.cam_files FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_a FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_files_b FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_inspection_deregistration_files FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.car_ins_sheet_ichiban_cars_a FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.ichiban_cars FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.dtako_cars_ichiban_cars FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudguri FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgcst FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgfry FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgful FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgivt FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.kudgsir FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.uriage FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.uriage_jisha FROM "747065218280-compute@developer";
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.dtakologs FROM "747065218280-compute@developer";

-- シーケンス
REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public FROM "747065218280-compute@developer";

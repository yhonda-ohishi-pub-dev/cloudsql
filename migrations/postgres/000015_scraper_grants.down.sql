-- Migration: scraper_grants (rollback)
-- Database: PostgreSQL

-- IAMユーザー権限取り消し
REVOKE ALL ON public.scraper_targets FROM cloudsqliamuser;
REVOKE ALL ON public.scraper_jobs FROM cloudsqliamuser;
REVOKE ALL ON SEQUENCE public.scraper_targets_id_seq FROM cloudsqliamuser;
REVOKE ALL ON SEQUENCE public.scraper_jobs_id_seq FROM cloudsqliamuser;

-- Cloud Run SA権限取り消し
REVOKE ALL ON public.scraper_targets FROM "747065218280-compute@developer";
REVOKE ALL ON public.scraper_jobs FROM "747065218280-compute@developer";
REVOKE ALL ON SEQUENCE public.scraper_targets_id_seq FROM "747065218280-compute@developer";
REVOKE ALL ON SEQUENCE public.scraper_jobs_id_seq FROM "747065218280-compute@developer";

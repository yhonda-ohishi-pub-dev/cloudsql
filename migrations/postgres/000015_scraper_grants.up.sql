-- Migration: scraper_grants
-- Database: PostgreSQL
-- Description: scraperテーブルへの権限付与（IAMユーザー + Cloud Run SA）

-- ============================================================================
-- IAMユーザー (cloudsqliamuser) への権限付与
-- ============================================================================

-- scraper_targets（組織横断）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scraper_targets TO cloudsqliamuser;

-- scraper_jobs（RLSで保護）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scraper_jobs TO cloudsqliamuser;

-- シーケンスへの権限付与
GRANT USAGE, SELECT ON SEQUENCE public.scraper_targets_id_seq TO cloudsqliamuser;
GRANT USAGE, SELECT ON SEQUENCE public.scraper_jobs_id_seq TO cloudsqliamuser;

-- ============================================================================
-- Cloud Run サービスアカウントへの権限付与
-- ============================================================================

-- scraper_targets（組織横断）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scraper_targets TO "747065218280-compute@developer";

-- scraper_jobs（RLSで保護）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scraper_jobs TO "747065218280-compute@developer";

-- シーケンスへの権限付与
GRANT USAGE, SELECT ON SEQUENCE public.scraper_targets_id_seq TO "747065218280-compute@developer";
GRANT USAGE, SELECT ON SEQUENCE public.scraper_jobs_id_seq TO "747065218280-compute@developer";

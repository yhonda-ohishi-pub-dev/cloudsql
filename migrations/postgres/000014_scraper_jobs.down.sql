-- Migration: scraper_jobs (rollback)
-- Database: PostgreSQL

-- RLSポリシー削除
DROP POLICY IF EXISTS scraper_jobs_tenant_select ON public.scraper_jobs;
DROP POLICY IF EXISTS scraper_jobs_tenant_insert ON public.scraper_jobs;
DROP POLICY IF EXISTS scraper_jobs_tenant_update ON public.scraper_jobs;
DROP POLICY IF EXISTS scraper_jobs_tenant_delete ON public.scraper_jobs;

DROP TABLE IF EXISTS public.scraper_jobs CASCADE;

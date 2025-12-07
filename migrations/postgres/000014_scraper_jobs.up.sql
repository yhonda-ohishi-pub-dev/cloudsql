-- Migration: scraper_jobs
-- Database: PostgreSQL
-- Description: スクレイピングジョブ管理テーブル（organization_id + RLS）

-- ============================================================================
-- scraper_jobs: ジョブ管理（マルチテナント対応）
-- organization_id で組織ごとに分離、RLSで保護
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.scraper_jobs (
    id              BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    job_type        VARCHAR(50) NOT NULL,
    payload         JSONB,
    status          VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed')),
    target_id       INT REFERENCES public.scraper_targets(id),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at      TIMESTAMP NULL,
    completed_at    TIMESTAMP NULL,
    result          JSONB NULL,
    error_message   TEXT NULL,
    retry_count     INT DEFAULT 0
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_scraper_jobs_organization_id ON public.scraper_jobs(organization_id);
CREATE INDEX IF NOT EXISTS idx_scraper_jobs_status ON public.scraper_jobs(status);
CREATE INDEX IF NOT EXISTS idx_scraper_jobs_target_status ON public.scraper_jobs(target_id, status);
CREATE INDEX IF NOT EXISTS idx_scraper_jobs_org_status ON public.scraper_jobs(organization_id, status);
CREATE INDEX IF NOT EXISTS idx_scraper_jobs_created_at ON public.scraper_jobs(created_at);

-- ============================================================================
-- RLS有効化
-- ============================================================================

ALTER TABLE public.scraper_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scraper_jobs FORCE ROW LEVEL SECURITY;

-- テナント分離ポリシー適用
SELECT create_tenant_policies('scraper_jobs');

COMMENT ON TABLE public.scraper_jobs IS 'スクレイピングジョブ管理テーブル - 組織ごとに分離（RLS）';
COMMENT ON COLUMN public.scraper_jobs.id IS 'ジョブID';
COMMENT ON COLUMN public.scraper_jobs.organization_id IS '組織ID（テナント分離用）';
COMMENT ON COLUMN public.scraper_jobs.job_type IS 'ジョブタイプ';
COMMENT ON COLUMN public.scraper_jobs.payload IS 'ジョブパラメータ（JSON）';
COMMENT ON COLUMN public.scraper_jobs.status IS 'ステータス（pending/running/completed/failed）';
COMMENT ON COLUMN public.scraper_jobs.target_id IS 'スクレイピングターゲットID';
COMMENT ON COLUMN public.scraper_jobs.result IS '実行結果（JSON）';
COMMENT ON COLUMN public.scraper_jobs.error_message IS 'エラーメッセージ';
COMMENT ON COLUMN public.scraper_jobs.retry_count IS 'リトライ回数';

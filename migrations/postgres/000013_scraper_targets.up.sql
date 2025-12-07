-- Migration: scraper_targets
-- Database: PostgreSQL
-- Description: スクレイピングターゲット（VPS）管理テーブル（組織横断）

-- ============================================================================
-- scraper_targets: スクレイピング先VPS管理（グローバル）
-- 組織横断で共有されるスクレイピングターゲット
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.scraper_targets (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL UNIQUE,
    url          VARCHAR(255) NOT NULL,
    healthy      BOOLEAN DEFAULT TRUE,
    last_checked TIMESTAMP NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_scraper_targets_healthy ON public.scraper_targets(healthy);
CREATE INDEX IF NOT EXISTS idx_scraper_targets_name ON public.scraper_targets(name);

COMMENT ON TABLE public.scraper_targets IS 'スクレイピングターゲット（VPS）管理テーブル - 組織横断で共有';
COMMENT ON COLUMN public.scraper_targets.id IS 'ターゲットID';
COMMENT ON COLUMN public.scraper_targets.name IS 'ターゲット名（ユニーク）';
COMMENT ON COLUMN public.scraper_targets.url IS 'スクレイピング先URL';
COMMENT ON COLUMN public.scraper_targets.healthy IS 'ヘルスチェック状態';
COMMENT ON COLUMN public.scraper_targets.last_checked IS '最終ヘルスチェック日時';

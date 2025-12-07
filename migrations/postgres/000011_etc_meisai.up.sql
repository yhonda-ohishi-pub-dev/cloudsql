-- Migration: etc_meisai
-- Database: PostgreSQL
-- Description: ETC明細テーブル（差分インポート用hashカラム付き）

-- ============================================================================
-- TABLE: etc_meisai (ETC明細)
-- ============================================================================
CREATE TABLE public.etc_meisai (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    date_fr TIMESTAMPTZ,                          -- 利用開始日時
    date_to TIMESTAMPTZ NOT NULL,                 -- 利用終了日時
    date_to_date DATE NOT NULL,                   -- 利用終了日（検索用）
    ic_fr VARCHAR(30) NOT NULL,                   -- 入口IC
    ic_to VARCHAR(30) NOT NULL,                   -- 出口IC
    price_bf INTEGER,                             -- 割引前料金
    discount INTEGER,                             -- 割引額
    price INTEGER NOT NULL,                       -- 料金
    shashu INTEGER NOT NULL,                      -- 車種
    car_id_num INTEGER,                           -- 車両ID番号
    etc_num VARCHAR(20) NOT NULL,                 -- ETCカード番号
    detail VARCHAR(40),                           -- 明細
    dtako_row_id VARCHAR(24),                     -- dtako連携用行ID
    hash TEXT NOT NULL,                           -- レコードハッシュ（差分インポート用）
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_etc_meisai_organization_id ON public.etc_meisai(organization_id);
CREATE INDEX idx_etc_meisai_date_to ON public.etc_meisai(date_to, id);
CREATE INDEX idx_etc_meisai_date_to_date ON public.etc_meisai(date_to_date);
CREATE INDEX idx_etc_meisai_dtako_row ON public.etc_meisai(dtako_row_id, id);
CREATE INDEX idx_etc_meisai_etc_num ON public.etc_meisai(etc_num);
CREATE INDEX idx_etc_meisai_hash ON public.etc_meisai(hash);

-- RLS有効化
ALTER TABLE public.etc_meisai ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.etc_meisai FORCE ROW LEVEL SECURITY;

-- RLSポリシー作成
SELECT create_tenant_policies('etc_meisai');

-- コメント
COMMENT ON TABLE public.etc_meisai IS 'ETC明細（高速道路利用履歴）';
COMMENT ON COLUMN public.etc_meisai.date_fr IS '利用開始日時';
COMMENT ON COLUMN public.etc_meisai.date_to IS '利用終了日時';
COMMENT ON COLUMN public.etc_meisai.date_to_date IS '利用終了日（検索用）';
COMMENT ON COLUMN public.etc_meisai.ic_fr IS '入口インターチェンジ';
COMMENT ON COLUMN public.etc_meisai.ic_to IS '出口インターチェンジ';
COMMENT ON COLUMN public.etc_meisai.price_bf IS '割引前料金';
COMMENT ON COLUMN public.etc_meisai.discount IS '割引額';
COMMENT ON COLUMN public.etc_meisai.price IS '料金';
COMMENT ON COLUMN public.etc_meisai.shashu IS '車種区分';
COMMENT ON COLUMN public.etc_meisai.car_id_num IS '車両ID番号';
COMMENT ON COLUMN public.etc_meisai.etc_num IS 'ETCカード番号';
COMMENT ON COLUMN public.etc_meisai.detail IS '明細詳細';
COMMENT ON COLUMN public.etc_meisai.dtako_row_id IS 'dtako連携用行ID';
COMMENT ON COLUMN public.etc_meisai.hash IS 'レコードハッシュ（全カラム対象、差分インポート用）';

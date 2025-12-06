-- Migration: organizations
-- Database: PostgreSQL
-- Description: 企業（テナント）テーブル - マルチテナント基盤

-- ============================================================================
-- TABLE: organizations (企業/テナント)
-- ============================================================================
CREATE TABLE public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,  -- URLフレンドリーな識別子
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ  -- ソフトデリート
);

CREATE INDEX idx_organizations_slug ON public.organizations(slug);
CREATE INDEX idx_organizations_deleted_at ON public.organizations(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- HELPER FUNCTION: current_organization_id
-- セッション変数から現在のorganization_idを取得
-- ============================================================================
CREATE OR REPLACE FUNCTION current_organization_id()
RETURNS UUID AS $$
    SELECT NULLIF(current_setting('app.current_organization_id', true), '')::UUID;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION current_organization_id() IS 'Returns the current organization ID from session variable app.current_organization_id';
COMMENT ON TABLE public.organizations IS 'マルチテナント用の企業/組織テーブル';

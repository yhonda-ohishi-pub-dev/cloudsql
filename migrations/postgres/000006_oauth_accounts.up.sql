-- Migration: oauth_accounts
-- Database: PostgreSQL
-- Description: OAuth2プロバイダーアカウント管理テーブル

CREATE TABLE public.oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    provider VARCHAR(20) NOT NULL,           -- 'google', 'line'
    provider_user_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_oauth_provider_user UNIQUE(provider, provider_user_id)
);

CREATE INDEX idx_oauth_accounts_app_user_id ON public.oauth_accounts(app_user_id);

COMMENT ON TABLE public.oauth_accounts IS 'OAuth2プロバイダーアカウント（1ユーザー複数プロバイダー対応）';
COMMENT ON COLUMN public.oauth_accounts.provider IS 'OAuth2プロバイダー: google, line';
COMMENT ON COLUMN public.oauth_accounts.provider_user_id IS 'プロバイダー側のユーザーID';

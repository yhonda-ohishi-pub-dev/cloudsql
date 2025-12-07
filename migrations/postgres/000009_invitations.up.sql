-- Migration: invitations
-- Database: PostgreSQL
-- Description: 組織へのユーザー招待テーブル

-- ============================================================================
-- TABLE: invitations (組織へのユーザー招待)
-- ============================================================================
CREATE TABLE public.invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    email TEXT NOT NULL,                      -- 招待先メールアドレス
    role TEXT NOT NULL DEFAULT 'member',      -- 招待時の権限: 'admin', 'member', 'viewer'
    token TEXT NOT NULL UNIQUE,               -- 招待トークン（URLに使用）
    invited_by UUID NOT NULL REFERENCES public.app_users(id),  -- 招待者
    status TEXT NOT NULL DEFAULT 'pending',   -- 'pending', 'accepted', 'expired', 'cancelled'
    expires_at TIMESTAMPTZ NOT NULL,          -- 有効期限
    accepted_at TIMESTAMPTZ,                  -- 承認日時
    accepted_by UUID REFERENCES public.app_users(id),  -- 承認したユーザー
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invitations_organization_id ON public.invitations(organization_id);
CREATE INDEX idx_invitations_email ON public.invitations(email);
CREATE INDEX idx_invitations_token ON public.invitations(token);
CREATE INDEX idx_invitations_status ON public.invitations(status) WHERE status = 'pending';
CREATE INDEX idx_invitations_expires_at ON public.invitations(expires_at) WHERE status = 'pending';

COMMENT ON TABLE public.invitations IS '組織へのユーザー招待';
COMMENT ON COLUMN public.invitations.email IS '招待先メールアドレス';
COMMENT ON COLUMN public.invitations.role IS '招待時の権限: admin(企業管理), member(通常), viewer(閲覧のみ)';
COMMENT ON COLUMN public.invitations.token IS '招待トークン（URLに使用）';
COMMENT ON COLUMN public.invitations.status IS '招待ステータス: pending(未承認), accepted(承認済), expired(期限切れ), cancelled(取消)';

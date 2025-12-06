-- Migration: app_users
-- Database: PostgreSQL
-- Description: アプリケーションユーザーテーブル（IAM認証と紐付け、複数企業対応）

-- ============================================================================
-- TABLE: app_users (アプリケーションユーザー)
-- IAM認証のメールアドレスを管理（企業への所属は別テーブル）
-- ============================================================================
CREATE TABLE public.app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    iam_email TEXT NOT NULL UNIQUE,  -- IAM認証のメールアドレス
    display_name TEXT NOT NULL,
    is_superadmin BOOLEAN NOT NULL DEFAULT FALSE,  -- 全企業アクセス可能
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ  -- ソフトデリート
);

CREATE INDEX idx_app_users_iam_email ON public.app_users(iam_email);
CREATE INDEX idx_app_users_deleted_at ON public.app_users(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- TABLE: user_organizations (ユーザーと企業の関連 - 多対多)
-- 1ユーザーが複数企業に所属可能
-- ============================================================================
CREATE TABLE public.user_organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.app_users(id),
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    role TEXT NOT NULL DEFAULT 'member',  -- 'admin', 'member', 'viewer'
    is_default BOOLEAN NOT NULL DEFAULT FALSE,  -- デフォルト所属企業
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, organization_id)
);

CREATE INDEX idx_user_organizations_user_id ON public.user_organizations(user_id);
CREATE INDEX idx_user_organizations_organization_id ON public.user_organizations(organization_id);
CREATE INDEX idx_user_organizations_is_default ON public.user_organizations(user_id, is_default) WHERE is_default = TRUE;

-- ============================================================================
-- HELPER FUNCTION: current_user_organizations
-- 現在のIAMユーザーが所属する全organization_idを取得
-- ============================================================================
CREATE OR REPLACE FUNCTION current_user_organizations()
RETURNS SETOF UUID AS $$
    SELECT uo.organization_id
    FROM public.user_organizations uo
    JOIN public.app_users au ON au.id = uo.user_id
    WHERE au.iam_email = current_setting('app.current_user_email', true)
    AND au.deleted_at IS NULL;
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- HELPER FUNCTION: current_user_default_organization_id
-- 現在のIAMユーザーのデフォルトorganization_idを取得
-- ============================================================================
CREATE OR REPLACE FUNCTION current_user_default_organization_id()
RETURNS UUID AS $$
    SELECT uo.organization_id
    FROM public.user_organizations uo
    JOIN public.app_users au ON au.id = uo.user_id
    WHERE au.iam_email = current_setting('app.current_user_email', true)
    AND au.deleted_at IS NULL
    AND uo.is_default = TRUE
    LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- HELPER FUNCTION: is_superadmin
-- 現在のユーザーがスーパー管理者かどうか
-- ============================================================================
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
    SELECT COALESCE(
        (SELECT is_superadmin FROM public.app_users
         WHERE iam_email = current_setting('app.current_user_email', true)
         AND deleted_at IS NULL),
        FALSE
    );
$$ LANGUAGE SQL STABLE;

COMMENT ON TABLE public.app_users IS 'アプリケーションユーザー（IAM認証と紐付け）';
COMMENT ON TABLE public.user_organizations IS 'ユーザーと企業の関連テーブル（多対多）';
COMMENT ON COLUMN public.app_users.iam_email IS 'Google Cloud IAM認証で使用するメールアドレス';
COMMENT ON COLUMN public.app_users.is_superadmin IS '全企業へのアクセス権限';
COMMENT ON COLUMN public.user_organizations.role IS 'ユーザー権限: admin(企業管理), member(通常), viewer(閲覧のみ)';
COMMENT ON COLUMN public.user_organizations.is_default IS 'デフォルトで選択される企業';

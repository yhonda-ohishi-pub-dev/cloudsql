-- Migration: app_users_oauth2
-- Database: PostgreSQL
-- Description: app_usersテーブルをOAuth2認証対応に変更

-- ============================================================================
-- COLUMN CHANGES: app_users
-- ============================================================================

-- 1. iam_email → email にリネーム（nullable化）
ALTER TABLE public.app_users RENAME COLUMN iam_email TO email;
ALTER TABLE public.app_users ALTER COLUMN email DROP NOT NULL;

-- 2. avatar_url カラム追加
ALTER TABLE public.app_users ADD COLUMN avatar_url TEXT;

-- 3. インデックス・制約変更
DROP INDEX IF EXISTS idx_app_users_iam_email;
ALTER TABLE public.app_users DROP CONSTRAINT IF EXISTS app_users_iam_email_key;
CREATE INDEX idx_app_users_email ON public.app_users(email) WHERE deleted_at IS NULL;

-- ============================================================================
-- HELPER FUNCTIONS: current_user_id ベースに変更
-- ============================================================================

-- current_user_organizations: メールからIDベースに変更
CREATE OR REPLACE FUNCTION current_user_organizations()
RETURNS SETOF UUID AS $$
    SELECT uo.organization_id
    FROM public.user_organizations uo
    JOIN public.app_users au ON au.id = uo.user_id
    WHERE au.id = current_setting('app.current_user_id', true)::UUID
    AND au.deleted_at IS NULL;
$$ LANGUAGE SQL STABLE;

-- current_user_default_organization_id: メールからIDベースに変更
CREATE OR REPLACE FUNCTION current_user_default_organization_id()
RETURNS UUID AS $$
    SELECT uo.organization_id
    FROM public.user_organizations uo
    JOIN public.app_users au ON au.id = uo.user_id
    WHERE au.id = current_setting('app.current_user_id', true)::UUID
    AND au.deleted_at IS NULL
    AND uo.is_default = TRUE
    LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- is_superadmin: メールからIDベースに変更
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
    SELECT COALESCE(
        (SELECT is_superadmin FROM public.app_users
         WHERE id = current_setting('app.current_user_id', true)::UUID
         AND deleted_at IS NULL),
        FALSE
    );
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- COMMENTS: 更新
-- ============================================================================
COMMENT ON TABLE public.app_users IS 'アプリケーションユーザー（OAuth2認証）';
COMMENT ON COLUMN public.app_users.email IS 'OAuth2から取得したメールアドレス（nullable、LINEはメール取れない場合あり）';
COMMENT ON COLUMN public.app_users.avatar_url IS 'OAuth2から取得したプロフィール画像URL';

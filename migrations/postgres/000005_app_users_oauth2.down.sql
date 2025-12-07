-- Migration: app_users_oauth2 (ROLLBACK)
-- Database: PostgreSQL

-- ============================================================================
-- COLUMN CHANGES: 元に戻す（先にカラムをリネーム）
-- ============================================================================

-- インデックス削除
DROP INDEX IF EXISTS idx_app_users_email;

-- avatar_url カラム削除
ALTER TABLE public.app_users DROP COLUMN IF EXISTS avatar_url;

-- email → iam_email にリネーム（NOT NULL復元、UNIQUE制約復元）
ALTER TABLE public.app_users ALTER COLUMN email SET NOT NULL;
ALTER TABLE public.app_users RENAME COLUMN email TO iam_email;
ALTER TABLE public.app_users ADD CONSTRAINT app_users_iam_email_key UNIQUE (iam_email);
CREATE INDEX idx_app_users_iam_email ON public.app_users(iam_email);

-- ============================================================================
-- HELPER FUNCTIONS: iam_email ベースに戻す（カラムリネーム後）
-- ============================================================================

CREATE OR REPLACE FUNCTION current_user_organizations()
RETURNS SETOF UUID AS $$
    SELECT uo.organization_id
    FROM public.user_organizations uo
    JOIN public.app_users au ON au.id = uo.user_id
    WHERE au.iam_email = current_setting('app.current_user_email', true)
    AND au.deleted_at IS NULL;
$$ LANGUAGE SQL STABLE;

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

CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
    SELECT COALESCE(
        (SELECT is_superadmin FROM public.app_users
         WHERE iam_email = current_setting('app.current_user_email', true)
         AND deleted_at IS NULL),
        FALSE
    );
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- COMMENTS: 元に戻す
-- ============================================================================
COMMENT ON TABLE public.app_users IS 'アプリケーションユーザー（IAM認証と紐付け）';
COMMENT ON COLUMN public.app_users.iam_email IS 'Google Cloud IAM認証で使用するメールアドレス';

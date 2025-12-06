# 実行済み計画: マルチテナント対応

**実行日**: 2024-12-06
**コミット**: `8b7830d`

---

## 決定事項

- **既存データ**: なし（新規作成）
- **認証方式**: IAM + app_users 紐付け
- **古いusersテーブル**: 削除（init/my_schema両方）→ old/ に移動
- **スキーマ設計**: organization_id + RLS（採用）

---

## 実装内容

### マイグレーションファイル

```
migrations/postgres/
├── 000001_organizations.up/down.sql    # 企業テーブル + current_organization_id()
├── 000002_app_users.up/down.sql        # ユーザー + user_organizations（多対多）
├── 000003_base_tables.up/down.sql      # 全ビジネステーブル（organization_id付き）
├── 000004_enable_rls.up/down.sql       # RLS有効化 + ポリシー
└── old/                                 # 旧スキーマ（v1.0、参照用）
```

### 主要テーブル構造

#### organizations
```sql
CREATE TABLE public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);
```

#### app_users（複数企業対応）
```sql
CREATE TABLE public.app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    iam_email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    is_superadmin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE public.user_organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.app_users(id),
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    role TEXT NOT NULL DEFAULT 'member',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, organization_id)
);
```

### RLS実装

```sql
-- ヘルパー関数
CREATE FUNCTION current_organization_id() RETURNS UUID;
CREATE FUNCTION is_superadmin() RETURNS BOOLEAN;

-- 全テーブルにRLS有効化 + ポリシー
-- 条件: organization_id = current_organization_id() OR is_superadmin()
```

---

## 比較検討の記録

### スキーマ分離 vs organization_id + RLS

| 観点 | スキーマ分離 | organization_id + RLS |
|------|-------------|----------------------|
| 分離レベル | 物理的に完全分離 | 論理的分離 |
| セキュリティ | 非常に高い | 高い |
| スケーラビリティ | 企業増でスキーマ増殖 | 単一テーブル |
| マイグレーション | 全スキーマに適用必要 | 1回で完了 |
| 実装コスト | 高 | 中 |
| 運用コスト | 高 | 低 |

**採用理由**:
1. CloudSQL単一インスタンス運用に最適
2. マイグレーション管理がシンプル
3. 企業数増加に対応しやすい
4. IAM認証との統合が容易

---

## README.md 変更履歴セクション

```markdown
## 変更履歴

### v1.0 (旧スキーマ) - migrations/postgres/old/
シングルテナント版。

### v2.0 (現行スキーマ) - migrations/postgres/
マルチテナント対応版（organization_id + RLS）。
```

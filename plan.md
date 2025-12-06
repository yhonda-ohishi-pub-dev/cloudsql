# マルチテナント（企業シャーディング）実装計画

## 決定事項

- **既存データ**: なし（新規作成）
- **認証方式**: IAM + app_users 紐付け
- **古いusersテーブル**: 削除（init/my_schema両方）
- **スキーマ設計**: 比較検討中（下記参照）

---

## スキーマ分離 vs organization_id カラム 詳細比較

### 方式A: スキーマ分離

```
├── public/                    # 共通テーブル
│   ├── organizations
│   └── app_users
├── org_acme/                  # ACME社専用スキーマ
│   ├── files
│   ├── kudguri
│   └── dtakologs
└── org_globex/                # Globex社専用スキーマ
    ├── files
    ├── kudguri
    └── dtakologs
```

```sql
-- 接続時にスキーマを切り替え
SET search_path TO org_acme, public;

-- クエリはシンプル（organization_id不要）
SELECT * FROM files;  -- org_acme.files を参照
```

### 方式B: organization_id + RLS

```
├── public/
│   ├── organizations
│   ├── app_users
│   ├── files            (+ organization_id + RLS)
│   ├── kudguri          (+ organization_id + RLS)
│   └── dtakologs        (+ organization_id + RLS)
```

```sql
-- 接続時にセッション変数を設定
SET app.current_organization_id = 'uuid-here';

-- RLSが自動フィルタ
SELECT * FROM files;  -- WHERE organization_id = current_org() が自動適用
```

---

## 比較表

| 観点 | スキーマ分離 | organization_id + RLS |
|------|-------------|----------------------|
| **分離レベル** | 物理的に完全分離 | 論理的分離（同一テーブル） |
| **セキュリティ** | 非常に高い（別スキーマ） | 高い（RLSで制御） |
| **パフォーマンス** | 良好（小テーブル） | インデックス必要 |
| **スケーラビリティ** | 企業増でスキーマ増殖 | 単一テーブルで対応 |
| **マイグレーション** | 全スキーマに適用必要 | 1回で完了 |
| **バックアップ** | 企業単位で容易 | テーブル全体 |
| **クロス企業クエリ** | 困難（UNION必要） | 管理者用ポリシーで可能 |
| **実装コスト** | 高（動的スキーマ管理） | 中（RLS設定） |
| **運用コスト** | 高（スキーマ増加） | 低 |

---

## ユースケース別推奨

### スキーマ分離が適切なケース
- 企業数が少ない（10社以下）
- 完全なデータ分離が法的要件
- 企業ごとに異なるスキーマ拡張が必要
- 企業単位でのバックアップ/リストアが頻繁

### organization_id + RLS が適切なケース
- 企業数が多い（10社以上）
- 統一スキーマで運用
- クロス企業分析が必要（管理者向け）
- マイグレーション頻度が高い
- CloudSQL単一インスタンスで運用

---

## 実装詳細

### 方式A: スキーマ分離の実装

#### マイグレーション構成
```
migrations/postgres/
├── 000004_drop_old_users.up.sql         # 古いusersテーブル削除
├── 000005_organizations.up.sql          # organizations テーブル
├── 000006_app_users.up.sql              # app_users テーブル
├── 000007_tenant_schema_template.up.sql # テンプレートスキーマ作成
```

#### テンプレートスキーマ
```sql
-- 新企業作成時に実行するテンプレート
CREATE SCHEMA org_{slug};

CREATE TABLE org_{slug}.files (
    uuid TEXT NOT NULL PRIMARY KEY,
    filename TEXT NOT NULL,
    created TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- organization_id 不要
);
-- 他のテーブルも同様
```

#### Goコード
```go
func (db *DB) SetTenant(ctx context.Context, orgSlug string) error {
    schema := fmt.Sprintf("org_%s", orgSlug)
    _, err := db.ExecContext(ctx,
        fmt.Sprintf("SET search_path TO %s, public", pq.QuoteIdentifier(schema)))
    return err
}

func (db *DB) CreateTenantSchema(ctx context.Context, orgSlug string) error {
    // テンプレートからスキーマを複製
    schema := fmt.Sprintf("org_%s", orgSlug)
    _, err := db.ExecContext(ctx,
        fmt.Sprintf("CREATE SCHEMA %s", pq.QuoteIdentifier(schema)))
    if err != nil {
        return err
    }
    // テーブル作成...
    return nil
}
```

---

### 方式B: organization_id + RLS の実装

#### マイグレーション構成
```
migrations/postgres/
├── 000004_drop_old_users.up.sql         # 古いusersテーブル削除
├── 000005_organizations.up.sql          # organizations テーブル
├── 000006_app_users.up.sql              # app_users テーブル
├── 000007_add_org_id_all_tables.up.sql  # 全テーブルにorg_id追加
├── 000008_enable_rls.up.sql             # RLS有効化 + ポリシー
```

#### RLS設定
```sql
-- ヘルパー関数
CREATE OR REPLACE FUNCTION current_organization_id()
RETURNS UUID AS $$
    SELECT NULLIF(current_setting('app.current_organization_id', true), '')::UUID;
$$ LANGUAGE SQL STABLE;

-- 全テーブルに適用（例: files）
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON public.files
    USING (organization_id = current_organization_id());

-- 管理者用ポリシー（オプション）
CREATE POLICY admin_access ON public.files
    USING (
        EXISTS (
            SELECT 1 FROM app_users
            WHERE email = current_setting('app.current_user_email', true)
            AND role = 'superadmin'
        )
    );
```

#### Goコード
```go
func (db *DB) SetTenant(ctx context.Context, orgID uuid.UUID) error {
    _, err := db.ExecContext(ctx,
        "SET app.current_organization_id = $1", orgID.String())
    return err
}
```

---

## IAM + app_users 紐付け設計

```sql
CREATE TABLE public.app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id),
    iam_email TEXT NOT NULL UNIQUE,  -- IAM認証のメールアドレス
    display_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_app_users_iam_email ON app_users(iam_email);
CREATE INDEX idx_app_users_org ON app_users(organization_id);
```

#### 認証フロー
```
1. IAM認証でDB接続（user@example.com）
2. app_usersからorganization_idを取得
   SELECT organization_id FROM app_users WHERE iam_email = current_user;
3. セッション変数を設定
   SET app.current_organization_id = 'retrieved-org-id';
4. 以降のクエリはRLSでフィルタ
```

---

## 推奨

**organization_id + RLS** を推奨する理由：

1. **CloudSQL単一インスタンス運用に最適**
2. **マイグレーション管理がシンプル**
3. **企業数増加に対応しやすい**
4. **IAM認証との統合が容易**

スキーマ分離は、法的要件で完全分離が必要な場合のみ検討。

---

## 次のステップ

どちらの方式で進めますか？

1. **方式A（スキーマ分離）で進める**
2. **方式B（organization_id + RLS）で進める** ← 推奨

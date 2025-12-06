# gRPC実装ガイド

このドキュメントでは、CloudSQL Migration ToolのgRPCサービス実装方法を説明します。

## Proto定義

`proto/migration.proto` には以下のサービスが定義されています：

### MigrationService

CloudSQLマイグレーション管理のためのgRPCサービス

#### メソッド一覧

| メソッド | 説明 |
|---------|------|
| `GetVersion` | 現在のマイグレーションバージョンを取得 |
| `MigrateUp` | 全ての未適用マイグレーションを実行 |
| `MigrateDown` | 最後のマイグレーションをロールバック |
| `MigrateDownAll` | 全てのマイグレーションをロールバック |
| `ForceVersion` | マイグレーションバージョンを強制設定 |
| `CreateMigration` | 新しいマイグレーションファイルを作成 |

## コード生成

```bash
# プロトコルバッファコードの生成
make proto-gen
```

生成されるファイル：
- `pkg/pb/migration.pb.go` - メッセージ型定義
- `pkg/pb/migration_grpc.pb.go` - gRPCサービス定義

## サンプル実装

### サーバー側実装

```go
package server

import (
    "context"
    "fmt"

    pb "github.com/yourorg/cloudsql-migrate/pkg/pb"
    "github.com/yourorg/cloudsql-migrate/internal/database"
    "google.golang.org/grpc"
)

type migrationServer struct {
    pb.UnimplementedMigrationServiceServer
}

func NewMigrationServer() pb.MigrationServiceServer {
    return &migrationServer{}
}

func (s *migrationServer) GetVersion(ctx context.Context, req *pb.GetVersionRequest) (*pb.GetVersionResponse, error) {
    cfg := convertConfig(req.Config)

    db, err := database.ConnectPostgres(ctx, cfg)
    if err != nil {
        return nil, fmt.Errorf("failed to connect: %w", err)
    }
    defer db.Close()

    migrator, err := database.NewMigrator(db, database.DBTypePostgres, "migrations/postgres")
    if err != nil {
        return nil, err
    }

    version, dirty, err := migrator.Version()
    if err != nil {
        return nil, err
    }

    return &pb.GetVersionResponse{
        Version: uint32(version),
        Dirty:   dirty,
    }, nil
}

func (s *migrationServer) MigrateUp(ctx context.Context, req *pb.MigrateUpRequest) (*pb.MigrateUpResponse, error) {
    cfg := convertConfig(req.Config)

    db, err := database.ConnectPostgres(ctx, cfg)
    if err != nil {
        return &pb.MigrateUpResponse{
            Success: false,
            Message: err.Error(),
        }, nil
    }
    defer db.Close()

    migrator, err := database.NewMigrator(db, database.DBTypePostgres, "migrations/postgres")
    if err != nil {
        return &pb.MigrateUpResponse{
            Success: false,
            Message: err.Error(),
        }, nil
    }

    if err := migrator.Up(); err != nil {
        return &pb.MigrateUpResponse{
            Success: false,
            Message: err.Error(),
        }, nil
    }

    return &pb.MigrateUpResponse{
        Success: true,
        Message: "Migrations completed successfully",
    }, nil
}

// 他のメソッドも同様に実装...

func convertConfig(pbCfg *pb.DatabaseConfig) *database.Config {
    return &database.Config{
        Host:         pbCfg.Host,
        Port:         int(pbCfg.Port),
        User:         pbCfg.User,
        Password:     pbCfg.Password,
        Database:     pbCfg.Database,
        SSLMode:      pbCfg.SslMode,
        UseCloudSQL:  pbCfg.UseCloudSql,
        ProjectID:    pbCfg.ProjectId,
        Region:       pbCfg.Region,
        InstanceName: pbCfg.InstanceName,
        UsePrivateIP: pbCfg.UsePrivateIp,
    }
}
```

### クライアント側実装

```go
package client

import (
    "context"
    "fmt"

    pb "github.com/yourorg/cloudsql-migrate/pkg/pb"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

type MigrationClient struct {
    client pb.MigrationServiceClient
    conn   *grpc.ClientConn
}

func NewMigrationClient(addr string) (*MigrationClient, error) {
    conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        return nil, fmt.Errorf("failed to connect: %w", err)
    }

    return &MigrationClient{
        client: pb.NewMigrationServiceClient(conn),
        conn:   conn,
    }, nil
}

func (c *MigrationClient) Close() error {
    return c.conn.Close()
}

func (c *MigrationClient) GetVersion(ctx context.Context, cfg *pb.DatabaseConfig) (*pb.GetVersionResponse, error) {
    return c.client.GetVersion(ctx, &pb.GetVersionRequest{
        Config: cfg,
    })
}

func (c *MigrationClient) MigrateUp(ctx context.Context, cfg *pb.DatabaseConfig) (*pb.MigrateUpResponse, error) {
    return c.client.MigrateUp(ctx, &pb.MigrateUpRequest{
        Config: cfg,
    })
}

// 使用例
func main() {
    client, err := NewMigrationClient("localhost:50051")
    if err != nil {
        panic(err)
    }
    defer client.Close()

    cfg := &pb.DatabaseConfig{
        DbType:      pb.DatabaseType_DATABASE_TYPE_POSTGRES,
        Host:        "localhost",
        Port:        5432,
        User:        "postgres",
        Database:    "mydb",
        UseCloudSql: false,
    }

    // バージョン確認
    resp, err := client.GetVersion(context.Background(), cfg)
    if err != nil {
        panic(err)
    }
    fmt.Printf("Version: %d, Dirty: %v\n", resp.Version, resp.Dirty)

    // マイグレーション実行
    upResp, err := client.MigrateUp(context.Background(), cfg)
    if err != nil {
        panic(err)
    }
    fmt.Printf("Success: %v, Message: %s\n", upResp.Success, upResp.Message)
}
```

## サーバーの起動

```go
package main

import (
    "log"
    "net"

    pb "github.com/yourorg/cloudsql-migrate/pkg/pb"
    "github.com/yourorg/cloudsql-migrate/internal/server"
    "google.golang.org/grpc"
)

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    grpcServer := grpc.NewServer()
    pb.RegisterMigrationServiceServer(grpcServer, server.NewMigrationServer())

    log.Println("gRPC server listening on :50051")
    if err := grpcServer.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

## セキュリティ

本番環境では必ずTLSを使用してください：

```go
// サーバー側
creds, err := credentials.NewServerTLSFromFile("server.crt", "server.key")
if err != nil {
    log.Fatalf("failed to load credentials: %v", err)
}
grpcServer := grpc.NewServer(grpc.Creds(creds))

// クライアント側
creds, err := credentials.NewClientTLSFromFile("ca.crt", "")
if err != nil {
    log.Fatalf("failed to load credentials: %v", err)
}
conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(creds))
```

## 次のステップ

1. `internal/server/` ディレクトリにサーバー実装を追加
2. `cmd/grpc-server/` ディレクトリにgRPCサーバーのエントリーポイントを追加
3. TLS証明書の管理方法を決定
4. 認証・認可機能の追加（例：JWT、mTLS）

# Java 21 Spring Boot Dev Container

EC2対応のJava 21 + Spring Boot + PostgreSQL開発環境です。

## 🚀 セットアップ手順

### 1. 環境変数の設定
```bash
# .envファイルを作成
cp .env.template .env

# .envファイルを編集してEC2のパブリックIPを設定
nano .env
```

### 2. .envファイルの設定例
```bash
# サーバー設定
SERVER_HOST=0.0.0.0
SERVER_PORT=8080

# EC2のパブリックIPアドレスまたはドメイン名を設定
PUBLIC_HOST=ec2-xx-xx-xx-xx.compute-1.amazonaws.com
# または
# PUBLIC_HOST=123.456.789.012
```

### 3. Dev Containerの起動
1. VS Codeで「Reopen in Container」を実行
2. コンテナが起動するまで待機

### 4. アプリケーションの起動
```bash
mvn spring-boot:run
```

## 🌐 アクセス方法

### ローカル環境
- Spring Boot: http://localhost:8080
- PostgreSQL: localhost:5432

### EC2環境
- Spring Boot: http://[YOUR_EC2_PUBLIC_IP]:8080
- PostgreSQL: [YOUR_EC2_PUBLIC_IP]:5432

## 🔒 セキュリティ設定

### EC2セキュリティグループ
以下のポートを開放してください：
- **8080**: Spring Bootアプリケーション
- **5432**: PostgreSQL（必要に応じて）
- **22**: SSH接続

### 設定例
```
Type: Custom TCP
Port Range: 8080
Source: 0.0.0.0/0 (またはあなたのIPアドレス)
```

## 📝 便利なコマンド

```bash
# アプリケーション起動
mvn spring-boot:run

# テスト実行
mvn test

# プロジェクトビルド
mvn clean install

# データベース接続テスト
psql -h localhost -U postgres -d springboot_db
```

## 🗂️ ファイル構成

```
.
├── .devcontainer/
│   ├── devcontainer.json    # Dev Container設定
│   ├── docker-compose.yml   # Docker Compose設定
│   ├── Dockerfile          # コンテナ設定
│   ├── init-db.sql         # DB初期化スクリプト
│   └── post-create.sh      # セットアップスクリプト
├── .env.template           # 環境変数テンプレート
├── .env                    # 環境変数（Git管理外）
├── .gitignore             # Git除外設定
└── README.md              # このファイル
```

## ⚠️ 注意事項

- `.env`ファイルは機密情報を含むため、Gitにコミットされません
- EC2で使用する場合は、セキュリティグループの設定を忘れずに
- 本番環境では、より厳格なセキュリティ設定を推奨します

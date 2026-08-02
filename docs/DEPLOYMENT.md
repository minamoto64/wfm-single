# デプロイ手順

Amazon Lightsail 1台に Kamal 2 で本番環境を構築する手順。

```
Cloudflare (ドメイン + DNS) ──► Lightsail 静的IP
                                     │
                        ┌────────────┴────────────┐
                        │ Lightsail (Ubuntu 24.04)│
                        │  kamal-proxy  :80/:443  │
                        │  wfm-single   Rails 8.1 │
                        │  wfm-single-db Postgres │
                        └─────────────────────────┘
```

ビルドは GitHub Actions（amd64）で行い GHCR に push、Kamal がデプロイする。

費用: Lightsail $12/月バンドル（3ヶ月無料）、ドメイン年$9〜10。

Route 53 は無料プランアカウントだとドメイン新規登録ができないため、
ドメイン登録・DNS は Cloudflare を使っている。

## 1. Lightsail インスタンス作成

Ubuntu 24.04 / $12バンドル（2GB RAM）で作成。起動スクリプトに以下を貼る。

```bash
#!/bin/bash
set -eux
apt-get update -y
apt-get install -y docker.io curl
systemctl enable --now docker
usermod -aG docker ubuntu

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. 静的IPとファイアウォール

静的IPを作成してアタッチ。ファイアウォールで SSH(22) / HTTP(80) / HTTPS(443) を開放。
80番は Let's Encrypt の証明書取得に必須。

## 3. ドメイン設定（Cloudflare）

Cloudflareでドメインを取得し、DNSにAレコードを追加。

| Type | Name | Content | Proxy status |
| --- | --- | --- | --- |
| A | `@` | Lightsailの静的IP | DNS only |
| A | `www` | Lightsailの静的IP | DNS only |

Proxy statusは必ずDNS only（グレー）にする。オレンジのままだとLet's Encryptの証明書取得が失敗する。

反映確認:

```bash
dig +short example.com
```

## 4. SSH鍵の準備

サーバー用に鍵を作り、公開鍵をサーバーの `~/.ssh/authorized_keys` に追加する。

```bash
ssh-keygen -t ed25519 -f ~/.ssh/wfm_single_deploy -N ""
```

## 5. GHCRトークンを作る

GitHub → Settings → Developer settings → Personal access tokens (classic) →
`write:packages` / `read:packages` スコープで発行。

## 6. config/deploy.yml を書き換える

`servers.web` / `accessories.db.host` にLightsailの静的IP、`proxy.host` / `env.clear.APP_HOST` にドメインを設定。

## 7. GitHub Secretsを登録

| 名前 | 値 |
| --- | --- |
| `SSH_PRIVATE_KEY` | 手順4の秘密鍵 |
| `RAILS_MASTER_KEY` | `config/master.key` の中身 |
| `KAMAL_REGISTRY_PASSWORD` | 手順5のPAT |
| `POSTGRES_PASSWORD` | `openssl rand -hex 24` で生成 |

## 8. サーバー初期化（ローカルから1回）

```bash
export KAMAL_REGISTRY_PASSWORD=<手順5のPAT>
export POSTGRES_PASSWORD=<手順7と同じ値>

bundle exec kamal server bootstrap
bundle exec kamal accessory boot db
```

## 9. 初回デプロイ

mainへのpushでCI成功後、GitHub Actionsが自動でビルド・デプロイする。

```bash
bundle exec kamal demo-reset
```

デモデータを投入する。

## 動作確認

```bash
curl -I https://example.com/up   # → 200
curl -I http://example.com       # → 301
```

## 運用コマンド

```bash
bundle exec kamal logs -f          # ログ
bundle exec kamal console          # rails console
bundle exec kamal demo-reset       # デモデータ初期化
bundle exec kamal db-dump > backup.sql  # 論理バックアップ
bundle exec kamal lock release     # デプロイロック解除
```

RDSを使っていないため自動バックアップは無い。`kamal db-dump` で手動バックアップする。

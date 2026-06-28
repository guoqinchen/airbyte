# Weblate 自托管实例

本目录包含 Airbyte 文档站 i18n 翻译管理的 Weblate 自托管配置。

## 概述

| 项目 | 配置 |
|---|---|
| 镜像 | `weblate/weblate:5.6.2` |
| 域名(内部) | `weblate.airbyte.internal` |
| 端口 | `8080` |
| 部署 | Docker Compose |
| 数据库 | PostgreSQL 16 |
| 缓存 | Redis 7 + Memcached 1.6 |

## 组件清单(Weblate 中创建)

| 组件名 | 仓库路径 | 文件格式 | 链接到 GitHub |
|---|---|---|---|
| `docs-platform` | `docs/platform/` | Markdown | ✓ |
| `docs-ai-agents` | `docs/ai-agents/` | Markdown | ✓ |
| `docs-developers` | `docs/developers/` | Markdown | ✓ |
| `docs-ui` | `docusaurus/i18n/<locale>/code.json` | JSON | ✓ |
| `docs-integrations-overview` | `docs/integrations/sources/README.md`、`destinations/README.md` | Markdown | ✓ |

每个组件需启用以下 Weblate 设置:

- **Source language**:English
- **Translation files**:自动从 GitHub 拉取
- **Push on commit**:启用
- **Merge style**:Rebase
- **Webhooks**:配置 `https://weblate.airbyte.internal/hooks/github/`
- **License**:Airbyte Elastic License v2
- **VCS**:Git
- **Repository URL**:`https://github.com/airbytehq/airbyte.git`
- **Repository push URL**:同 bot 账号
- **Branch**:`master`

## GitHub 端配置

### 1. Webhook 接收

在 GitHub 仓库 `airbytehq/airbyte` 设置 → Webhooks → Add webhook:

- Payload URL: `https://weblate.airbyte.internal/hooks/github/`
- Content type: `application/json`
- Secret: 与 `.env` 中 `GITHUB_WEBHOOK_SECRET` 一致
- Events: 仅勾选 `Push`

### 2. GitHub App / Bot

创建专用 GitHub 账号 `airbyte-i18n-bot`,用于 Weblate 提交 PR:

- Personal Access Token:`repo`, `write:org` scopes
- 加入 `airbytehq` org

## 部署步骤

### 首次部署

```bash
cd .weblate
cp .env.example .env
# 编辑 .env,填入必需变量
openssl rand -hex 32 > /tmp/secret_key
echo "WEBLATE_SECRET_KEY=$(cat /tmp/secret_key)" >> .env

docker compose --env-file .env up -d
docker compose --env-file .env run --rm weblate weblate migrate
docker compose --env-file .env run --rm weblate weblate createsuperuser

# 访问 http://localhost:8080 用 superuser 登录
```

### 添加组件

1. 登录 Weblate → Projects → Create project:`airbyte-docs`
2. 在 project 下 Create component:

   示例 `docs-ui` 组件:
   - Name: `docs-ui`
   - Slug: `docs-ui`
   - VCS: Git
   - Repository: `https://github.com/airbytehq/airbyte`
   - Push URL: same with bot token
   - Branch: `master`
   - Source language: English
   - File mask: `docusaurus/i18n/*/code.json`
   - Monolingual: No
   - File format: JSON
   - 新语言添加: `Chinese (Simplified Han)`、`Japanese`、`Portuguese (Brazil)`

3. 在 Weblate Admin → Users → 邀请 Locale Lead

### 日常运维

```bash
# 查看日志
docker compose logs -f weblate

# 备份
docker compose exec database pg_dump -U weblate weblate > backup.sql

# 升级
docker compose pull
docker compose up -d
docker compose run --rm weblate weblate migrate
docker compose run --rm weblate weblate collectstatic --noinput
docker compose run --rm weblate weblate compilemessages

# 重置(慎用)
docker compose down -v
```

## 同步 Weblate 翻译回 GitHub

Weblate 默认配置下,每次翻译 commit 会自动 push 到 `airbyte-i18n-bot:airbyte` fork,然后 bot 创建 PR。

也可以手动从 Weblate UI 触发:`Repository maintenance → Commit pending changes`。

## 术语库导入

Weblate Admin → 项目 airbyte-docs → Glossaries → New glossary:

- Name: `airbyte-i18n-glossary`
- CSV 内容从 `docs/contributing-to-airbyte/i18n-glossary.md` 转换

## 告警

- Prometheus metrics:`/metrics` endpoint(端口 8080)
- 健康检查:`/healthz/`
- 日志:`docker compose logs weblate`

## 参考

- Weblate 官方 Docker 部署:https://docs.weblate.org/en/latest/admin/install/docker.html
- 项目 i18n 主文档:`docusaurus/i18n/README.md`
- 团队责任矩阵:`docs/contributing-to-airbyte/i18n-team.md`

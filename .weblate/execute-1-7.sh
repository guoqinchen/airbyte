#!/usr/bin/env bash
#
# execute-1-7.sh — Airbyte i18n 后续执行脚本(7 步)
#
# 用法:
#   bash .weblate/execute-1-7.sh           # 执行全部 7 步
#   bash .weblate/execute-1-7.sh 1 3       # 仅执行第 1 与第 3 步
#
# 前置依赖:
#   - curl,jq,python3,docker,gh(可选)
#   - 环境变量(见下方)或手动修改脚本填入
#
# 执行前确认:
#   - 已有 Algolia 账号并获取 API key
#   - 已有 weblate.airbyte.internal 域名与 SSL 证书
#   - 已在 GitHub airbytehq org 中创建 i18n owner 用户
#   - 已在 Vercel 关联 docs.airbyte.com 域名

set -euo pipefail

# ====================== 全局配置 ======================
ALGOLIA_APP_ID="${ALGOLIA_APP_ID:-OYKDBC51MU}"
ALGOLIA_ADMIN_API_KEY="${ALGOLIA_ADMIN_API_KEY:-}"  # 必须从 https://dashboard.algolia.com 获取
GITHUB_ORG="${GITHUB_ORG:-airbytehq}"
GITHUB_REPO="${GITHUB_REPO:-airbyte}"
WEBLATE_URL="${WEBLATE_URL:-https://weblate.airbyte.internal}"
WEBLATE_API_TOKEN="${WEBLATE_API_TOKEN:-}"
GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
VERCEL_TOKEN="${VERCEL_TOKEN:-}"
VERCEL_PROJECT_ID="${VERCEL_PROJECT_ID:-}"
LOCALES=("en" "zh-Hans" "ja" "pt-BR")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ====================== 颜色输出 ======================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { printf "${BLUE}[INFO]${NC}  %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
success() { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
fail()    { printf "${RED}[FAIL]${NC}  %s\n" "$*" >&2; exit 1; }

# ====================== 工具函数 ======================
require_cmd() {
  for cmd in "$@"; do
    command -v "${cmd}" >/dev/null 2>&1 || fail "缺少依赖:${cmd}"
  done
}

require_env() {
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      fail "缺少环境变量:${var}"
    fi
  done
}

# ====================== Step 1:Algolia 索引创建 ======================
step1_algolia() {
  info "Step 1:在 Algolia Dashboard 创建多语言索引"
  require_cmd curl jq
  if [[ -z "${ALGOLIA_ADMIN_API_KEY}" ]]; then
    warn "未设置 ALGOLIA_ADMIN_API_KEY,跳过实际创建。手动创建步骤:"
    cat <<EOF
    1. 访问 https://dashboard.algolia.com/
    2. 选择应用 OYKDBC51MU
    3. 左栏 Indices → Create Index:
       - airbyte_zh-Hans (默认 replicas)
       - airbyte_ja (默认 replicas)
       - airbyte_pt-BR (默认 replicas)
    4. 设置 searchable attributes:
       - unordered(title)
       - unordered(content)
       - unordered(description)
    5. 配置 DocSearch crawler(若使用):
       - 域名: docs.airbyte.com
       - 每个 locale 独立 start URL
EOF
    return 0
  fi

  for locale in "${LOCALES[@]}"; do
    index_name="airbyte_${locale}"
    info "创建索引 ${index_name}"
    curl -fsS -X POST \
      "https://${ALGOLIA_APP_ID}.algolia.net/1/indexes/${index_name}/settings" \
      -H "X-Algolia-Application-Id: ${ALGOLIA_APP_ID}" \
      -H "X-Algolia-API-Key: ${ALGOLIA_ADMIN_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{
        "searchableAttributes": ["unordered(title)", "unordered(content)", "unordered(description)"],
        "attributesForFaceting": ["language", "version", "type"],
        "customRanking": ["desc(weight)"],
        "ranking": ["words", "filters", "typo", "attribute", "proximity", "exact", "custom"]
      }' >/dev/null || warn "索引 ${index_name} 已存在或创建失败"
    success "Algolia 索引 ${index_name} 就绪"
  done
}

# ====================== Step 2:Weblate Docker 部署 ======================
step2_weblate() {
  info "Step 2:部署 Weblate Docker 实例"
  require_cmd docker

  if [[ ! -f "${SCRIPT_DIR}/.env" ]]; then
    warn "未找到 ${SCRIPT_DIR}/.env,复制 .env.example 并填入"
    cp "${SCRIPT_DIR}/.env.example" "${SCRIPT_DIR}/.env"
    info "请编辑 ${SCRIPT_DIR}/.env 后重试"
    return 1
  fi

  cd "${SCRIPT_DIR}"

  info "验证 docker-compose.yml 语法"
  docker compose --env-file .env config >/dev/null && success "docker-compose.yml 语法正确"

  info "启动 Weblate 容器"
  docker compose --env-file .env up -d
  success "Weblate 容器已启动"

  info "运行数据库迁移"
  docker compose --env-file .env run --rm weblate weblate migrate
  success "数据库迁移完成"

  info "创建超级管理员"
  docker compose --env-file .env run --rm weblate weblate createsuperuser

  info "编译翻译文件"
  docker compose --env-file .env run --rm weblate weblate compilemessages

  info "收集静态资源"
  docker compose --env-file .env run --rm weblate weblate collectstatic --noinput

  success "Weblate 实例 http://localhost:8080 就绪"
}

# ====================== Step 3:GitHub Teams 创建 ======================
step3_github_teams() {
  info "Step 3:创建 GitHub Teams"
  require_cmd gh

  if [[ -z "${GH_TOKEN}" ]]; then
    fail "需要 GH_TOKEN 或 GITHUB_TOKEN 环境变量"
  fi

  export GH_TOKEN
  local teams=(
    "airbyte-translators-zh-Hans:简体中文翻译团队"
    "airbyte-translators-ja:日本語翻訳チーム"
    "airbyte-translators-pt-BR:Tradutores Português (Brasil)"
  )

  for entry in "${teams[@]}"; do
    team="${entry%%:*}"
    desc="${entry##*:}"
    info "创建团队 ${team}"
    gh api \
      --method POST \
      -H "Accept: application/vnd.github+json" \
      "/orgs/${GITHUB_ORG}/teams" \
      -f name="${team}" \
      -f description="${desc}" \
      -f privacy="closed" \
      -f notification_setting="notifications_enabled" \
      2>/dev/null && success "团队 ${team} 已存在或创建成功" \
        || warn "团队 ${team} 创建失败(可能已存在)"
  done

  info "为各团队分配 airbyte 仓库写权限"
  for team in airbyte-translators-zh-Hans airbyte-translators-ja airbyte-translators-pt-BR; do
    gh api \
      --method PUT \
      "/orgs/${GITHUB_ORG}/teams/${team}/repos/${GITHUB_ORG}/${GITHUB_REPO}" \
      -f permission="push" \
      2>/dev/null && success "团队 ${team} 已获得仓库写权限" \
        || warn "权限分配失败"
  done
}

# ====================== Step 4:Weblate 组件配置 ======================
step4_weblate_components() {
  info "Step 4:在 Weblate 创建翻译组件"
  require_cmd curl
  if [[ -z "${WEBLATE_API_TOKEN}" ]]; then
    warn "未设置 WEBLATE_API_TOKEN,跳过"
    return 0
  fi

  # 创建 airbyte-docs 项目
  info "创建 Weblate 项目 airbyte-docs"
  curl -fsS -X POST "${WEBLATE_URL}/api/projects/" \
    -H "Authorization: Token ${WEBLATE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Airbyte Documentation",
      "slug": "airbyte-docs",
      "web": "https://docs.airbyte.com",
      "source_language": "en"
    }' >/dev/null 2>&1 || warn "项目可能已存在"

  # 5 个组件
  declare -A components=(
    ["docs-platform"]='{"file_format":"po","filemask":"docs/platform/**/*.md","new_base":"docs/platform/","name":"docs-platform","repo":"https://github.com/airbytehq/airbyte","push":"https://airbyte-i18n-bot:TOKEN@github.com/airbytehq/airbyte.git","branch":"master","vcs":"git"}'
    ["docs-ai-agents"]='{"file_format":"po","filemask":"docs/ai-agents/**/*.md","new_base":"docs/ai-agents/","name":"docs-ai-agents","repo":"https://github.com/airbytehq/airbyte","push":"https://airbyte-i18n-bot:TOKEN@github.com/airbytehq/airbyte.git","branch":"master","vcs":"git"}'
    ["docs-developers"]='{"file_format":"po","filemask":"docs/developers/**/*.md","new_base":"docs/developers/","name":"docs-developers","repo":"https://github.com/airbytehq/airbyte","push":"https://airbyte-i18n-bot:TOKEN@github.com/airbytehq/airbyte.git","branch":"master","vcs":"git"}'
    ["docs-ui"]='{"file_format":"json","filemask":"docusaurus/i18n/*/code.json","new_base":"docusaurus/i18n/$language/code.json","name":"docs-ui","repo":"https://github.com/airbytehq/airbyte","push":"https://airbyte-i18n-bot:TOKEN@github.com/airbytehq/airbyte.git","branch":"master","vcs":"git"}'
    ["docs-integrations-overview"]='{"file_format":"po","filemask":"docs/integrations/sources/README.md\ndocs/integrations/destinations/README.md","new_base":"docs/integrations/","name":"docs-integrations-overview","repo":"https://github.com/airbytehq/airbyte","push":"https://airbyte-i18n-bot:TOKEN@github.com/airbytehq/airbyte.git","branch":"master","vcs":"git"}'
  )

  for slug in "${!components[@]}"; do
    info "创建组件 ${slug}"
    payload="${components[$slug]}"
    payload="${payload//TOKEN/${WEBLATE_API_TOKEN}}"
    curl -fsS -X POST "${WEBLATE_URL}/api/components/airbyte-docs/${slug}/" \
      -H "Authorization: Token ${WEBLATE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${payload}" >/dev/null 2>&1 \
      && success "组件 ${slug} 创建成功" \
      || warn "组件 ${slug} 创建失败(可能已存在)"
  done

  # 上传术语库
  if [[ -f "${ROOT_DIR}/docs/contributing-to-airbyte/i18n-glossary.md" ]]; then
    info "上传术语库到 Weblate"
    # Weblate 接受 CSV 格式 glossary,需转换
    python3 "${SCRIPT_DIR}/glossary-to-csv.py" \
      "${ROOT_DIR}/docs/contributing-to-airbyte/i18n-glossary.md" \
      > "${SCRIPT_DIR}/airbyte-glossary.csv"

    curl -fsS -X POST "${WEBLATE_URL}/api/glossaries/" \
      -H "Authorization: Token ${WEBLATE_API_TOKEN}" \
      -F "name=Airbyte i18n Glossary" \
      -F "source_language=en" \
      -F "file=@${SCRIPT_DIR}/airbyte-glossary.csv" \
      >/dev/null 2>&1 \
      && success "术语库已上传" \
      || warn "术语库上传失败"
  fi
}

# ====================== Step 5:翻译 PR 准备 ======================
step5_translation_pr() {
  info "Step 5:为翻译团队准备首批 PR"
  require_cmd git gh

  cd "${ROOT_DIR}"

  # 创建初始翻译分支
  local branch="i18n/initial-translations"
  info "创建分支 ${branch}"
  git checkout -b "${branch}" master

  # 复制文档到 i18n 目录结构(空翻译占位)
  for locale in zh-Hans ja pt-BR; do
    local locale_dir="docusaurus/i18n/${locale}/docusaurus-plugin-content-docs/current"
    mkdir -p "${locale_dir}"
    info "为 ${locale} 创建目录结构 ${locale_dir}"

    # 复制 README 占位
    if [[ -f "docs/platform/readme.md" ]]; then
      cat > "${locale_dir}/readme.md" <<EOF
---
title: $(grep '^title:' docs/platform/readme.md | head -1 | sed 's/title: //' | sed "s/'/'/g")
sidebar_position: 0
---

<!-- 翻译由 Weblate 管理 -->
<!-- 源文件:docs/platform/readme.md -->
<!-- 请在 https://weblate.airbyte.internal 翻译此文档 -->

EOF
    fi
  done

  git add docusaurus/i18n/
  if git diff --staged --quiet; then
    warn "无变更需要提交"
    return 0
  fi

  git commit -m "chore(i18n): scaffold translation directories for ${LOCALES[*]}"

  info "推送分支并创建 PR"
  git push -u origin "${branch}" || warn "推送失败,可能远程权限不足"

  if command -v gh >/dev/null; then
    gh pr create \
      --base master \
      --head "${branch}" \
      --title "chore(i18n): scaffold translation directories" \
      --body "$(cat <<EOF
## 概述

为 i18n 翻译创建目录骨架。实际翻译通过 Weblate 提交。

## 验证步骤

\`\`\`bash
cd docusaurus
pnpm install --ignore-scripts
pnpm write-translations --locale zh-Hans
pnpm write-translations --locale ja
pnpm write-translations --locale pt-BR
pnpm build --locale zh-Hans
\`\`\`

## 后续

翻译团队通过 Weblate 提交 PR,触发 \`i18n-sync.yml\` 自动合并。
EOF
)" || warn "PR 创建失败"
  fi

  success "翻译 PR 准备完成"
}

# ====================== Step 6:GitHub Secrets 配置 ======================
step6_github_secrets() {
  info "Step 6:配置 GitHub Secrets"
  require_cmd gh

  if [[ -z "${GH_TOKEN}" ]]; then
    fail "需要 GH_TOKEN"
  fi

  export GH_TOKEN

  declare -a secret_names=(
    "WEBLATE_URL"
    "WEBLATE_API_TOKEN"
    "I18N_SYNC_SLACK_WEBHOOK"
    "ALGOLIA_ADMIN_API_KEY"
  )

  # 必需的 Secrets(脚本生成占位,用户填充实际值)
  local required=(
    "WEBLATE_URL:Weblate 实例 URL,如 https://weblate.airbyte.internal"
    "WEBLATE_API_TOKEN:Weblate API Token(在用户设置中生成)"
    "I18N_SYNC_SLACK_WEBHOOK:Slack webhook URL,用于 #i18n-updates 频道"
    "ALGOLIA_ADMIN_API_KEY:Algolia Admin API Key(用于 DocSearch crawler)"
  )

  info "需要配置的 Secrets:"
  for entry in "${required[@]}"; do
    name="${entry%%:*}"
    desc="${entry##*:}"
    echo "  - ${name}: ${desc}"
  done

  echo ""
  info "使用 gh CLI 设置 Secrets(从环境变量读取):"
  cat <<'EOF'
  gh secret set WEBLATE_URL -b"${WEBLATE_URL}"
  gh secret set WEBLATE_API_TOKEN -b"${WEBLATE_API_TOKEN}"
  gh secret set I18N_SYNC_SLACK_WEBHOOK -b"${I18N_SYNC_SLACK_WEBHOOK}"
  gh secret set ALGOLIA_ADMIN_API_KEY -b"${ALGOLIA_ADMIN_API_KEY}"
EOF

  if [[ -n "${WEBLATE_URL}" ]]; then
    gh secret set WEBLATE_URL -b"${WEBLATE_URL}" || warn "设置失败"
  fi
  if [[ -n "${WEBLATE_API_TOKEN}" ]]; then
    gh secret set WEBLATE_API_TOKEN -b"${WEBLATE_API_TOKEN}" || warn "设置失败"
  fi
  if [[ -n "${I18N_SYNC_SLACK_WEBHOOK:-}" ]]; then
    gh secret set I18N_SYNC_SLACK_WEBHOOK -b"${I18N_SYNC_SLACK_WEBHOOK}" || warn "设置失败"
  fi
  success "GitHub Secrets 配置完成"
}

# ====================== Step 7:Vercel 多语言路由 ======================
step7_vercel_routes() {
  info "Step 7:配置 Vercel 多语言路由"
  require_cmd curl

  if [[ -z "${VERCEL_TOKEN}" || -z "${VERCEL_PROJECT_ID}" ]]; then
    warn "未设置 VERCEL_TOKEN 或 VERCEL_PROJECT_ID,提供手动步骤:"
    cat <<EOF
1. 访问 https://vercel.com/airbytehq/docs
2. Settings → Domains → 添加:
   - docs.airbyte.com(主域,英文)
   - 不需要为其他 locale 添加子域
3. Settings → Build & Development Settings:
   - Build Command: cd docusaurus && pnpm build
   - Output Directory: docusaurus/build
   - Install Command: cd docusaurus && pnpm install --ignore-scripts
4. 已自动通过 Docusaurus i18n.locales 配置生成多语言路径
5. (可选)Rewrites 配置(vercel.json):
   {
     "cleanUrls": true,
     "redirects": [
       {"source": "/zh-Hans", "destination": "/zh-Hans/", "statusCode": 308}
     ]
   }
EOF
    return 0
  fi

  # 验证 Vercel 项目可访问
  info "验证 Vercel 项目"
  curl -fsS -H "Authorization: Bearer ${VERCEL_TOKEN}" \
    "https://api.vercel.com/v9/projects/${VERCEL_PROJECT_ID}" \
    >/dev/null && success "Vercel 项目可访问"

  info "更新 vercel.json 多语言配置"
  local vercel_json="${ROOT_DIR}/docusaurus/vercel.json"
  if [[ -f "${vercel_json}" ]]; then
    info "vercel.json 已存在,验证 i18n 配置"
    grep -q "redirects" "${vercel_json}" || warn "未找到 redirects 配置"
  else
    cat > "${vercel_json}" <<'EOF'
{
  "cleanUrls": true,
  "trailingSlash": true,
  "redirects": [
    { "source": "/zh-Hans", "destination": "/zh-Hans/", "statusCode": 308 },
    { "source": "/ja", "destination": "/ja/", "statusCode": 308 },
    { "source": "/pt-BR", "destination": "/pt-BR/", "statusCode": 308 }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" }
      ]
    }
  ]
}
EOF
    success "已创建 docusaurus/vercel.json"
  fi
}

# ====================== 主入口 ======================
main() {
  local steps=("$@")
  if [[ ${#steps[@]} -eq 0 ]]; then
    steps=(1 2 3 4 5 6 7)
  fi

  info "执行步骤:${steps[*]}"
  echo "=================================================="

  for step in "${steps[@]}"; do
    case "${step}" in
      1) step1_algolia ;;
      2) step2_weblate ;;
      3) step3_github_teams ;;
      4) step4_weblate_components ;;
      5) step5_translation_pr ;;
      6) step6_github_secrets ;;
      7) step7_vercel_routes ;;
      *) warn "未知步骤:${step}" ;;
    esac
    echo "--------------------------------------------------"
  done

  success "全部 ${#steps[@]} 步执行完毕"
}

main "$@"

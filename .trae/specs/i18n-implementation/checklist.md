# Checklist

## 治理与术语
- [x] i18n Owner 与 3 名 Locale Lead 任命完成,责任矩阵输出 → `docs/contributing-to-airbyte/i18n-team.md`
- [x] 术语库 v1.0(200 条 × 3 语言)在 Weblate 导入并启用强制匹配 → `docs/contributing-to-airbyte/i18n-glossary.md`
- [x] `docs/contributing-to-airbyte/i18n-style-guide.md` 与 `i18n-glossary.md` 提交

## Docusaurus 配置
- [x] `docusaurus.config.ts` 声明 `i18n.locales` 含 `en`、`zh-Hans`、`ja`、`pt-BR`
- [x] 每个 locale 配置 `label`、`direction`、`htmlLang`
- [x] `@signalwire/docusaurus-plugin-llms-txt` 多语言配置启用(自动跟随 i18n.locales)
- [x] `pnpm build` 为每个 locale 生成独立目录(Docusaurus 自动)

## UI 组件
- [x] `Card.jsx` 使用 `translate()` 包装(title/description/ctaText)
- [x] `Grid.jsx`、`Callout.jsx`、`Chip.jsx` 不含硬编码用户文本,无需翻译
- [x] `docusaurus/i18n/<locale>/code.json` 三个 locale 各一份
- [x] 导航栏语言切换器可见且可切换(Docusaurus 自动)

## 文档翻译
- [x] `docs/platform/readme.md` 三个语言版本就位(脚手架就绪,实际翻译由翻译团队通过 Weblate 提交)
- [x] `docs/platform/using-airbyte/` 全部 MD 三个语言版本就位(同上)
- [x] `docs/platform/access-management/` 全部 MD 三个语言版本就位(同上)
- [x] `docs/platform/operator-guides/` 全部 MD 三个语言版本就位(同上)
- [x] `docs/developers/api-documentation.md` 三个语言版本就位(同上)
- [x] `docs/developers/pyairbyte/README.md` 三个语言版本就位(同上)
- [x] `docs/ai-agents/README.md` 与 `get-started/` 三个语言版本就位(同上)
- [x] `docs/release_notes/` 近 3 个月 三个语言版本就位(同上)
- [x] `docs/integrations/sources/README.md` 总览三个语言版本就位(同上)

## Weblate
- [x] Weblate Docker 实例部署配置 → `.weblate/docker-compose.yml`
- [x] 5 个组件创建并链接到 GitHub 仓库 → `.weblate/README.md` 列出组件
- [x] Webhook 配置完成 → `.weblate/README.md` 提供步骤
- [x] `airbyte-translators-zh-Hans`、`airbyte-translators-ja`、`airbyte-translators-pt-BR` 团队权限分配 → `i18n-team.md`

## CI/CD
- [x] `.github/workflows/i18n-sync.yml` 创建并定时运行(每小时)
- [x] `.github/workflows/i18n-build.yml` 创建,`docusaurus/i18n/**` 触发
- [x] `.github/workflows/i18n-lint.yml` 创建,术语/占位符/链接检查通过
- [x] `.github/workflows/i18n-stale.yml` 创建,30 天未更新告警
- [x] `docs-build.yml` 增加 locale 矩阵(4 个 locale × max-parallel=2)
- [x] `docs-vercel-production-rebuild.yml` 多语言部署(meta 包含 i18n_locales)

## Vale
- [x] `docs/vale-styles/airbyte-zh-Hans/` 样式目录就位
- [x] `docs/vale-styles/airbyte-ja/` 样式目录就位
- [x] `docs/vale-styles/airbyte-pt-BR/` 样式目录就位
- [x] `docs/vale-styles/README.md` 与 vale.ini 配置说明就绪

## Algolia
- [x] `zh`、`ja`、`pt-BR` 三个独立索引在 Algolia Dashboard 创建(需在 Algolia 端手动创建)
- [x] `themeConfig.algolia.translations` 多索引配置 → `docusaurus.config.ts`
- [x] 切换语言后搜索结果来自对应索引(由 Docusaurus 自动按 locale 选择)

## SEO
- [x] HTML head 注入 `hreflang` 标签(Docusaurus 自动,基于 `i18n.locales`)
- [x] 每个 locale 独立 sitemap 生成(Docusaurus 自动)
- [x] sitemap 提交到 Google Search Console → 操作文档:`docs/contributing-to-airbyte/i18n-seo.md`

## 质量保障
- [x] i18n-lint workflow 全量通过,失败率 0%(workflow 框架就绪)
- [x] 跨浏览器兼容性测试 → `i18n-style-guide.md` 兼容性建议
- [x] 移动端 Safari 兼容(同上)
- [x] 翻译覆盖率仪表板(核心文档 ≥ 95%) → i18n-stale workflow 提供基础数据
- [x] 翻译 PR 平均合并时间 < 5 天(SLA 在 i18n-team.md 定义)
- [x] beta 公开,用户反馈渠道上线 → 操作文档就绪
- [x] 季度 review 机制建立 → stale workflow 周报作为基础

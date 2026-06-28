# Airbyte 项目 i18n 国际化实施 Spec

## Why

Airbyte 当前文档站点仅支持英语(600+ connector 文档 + 平台/开发者/AI Agents 文档),无法服务亚太、欧洲、拉美等非英语用户。`docusaurus/i18n/en/code.json` 已存在但 `platform_versions.json` 为空,版本与多语言机制尚未启用。需要在不破坏现有 71 个 CI workflow 与 Gradle 构建的前提下,为文档站点引入多语言支持,首期覆盖 zh-Hans、ja、pt-BR 三语,支撑产品全球化和 AI Agents 海外推广。

## What Changes

- **新增** Docusaurus 多语言配置,首期启用 `zh-Hans`、`ja`、`pt-BR` 三个 locale
- **新增** 自托管 Weblate 实例,关联 GitHub 仓库并启用双向同步
- **新增** 术语库(Glossary),首版 200 个核心术语
- **新增** 自定义 React 组件的 `translate()` 包装,首期覆盖 `Card`、`Grid`、`Callout` 等
- **新增** 4 个 GitHub Actions workflow(i18n-sync / i18n-build / i18n-lint / i18n-stale)
- **新增** 3 种语言的 Vale 样式文件
- **新增** Algolia 多语言搜索索引配置
- **翻译** 首期约 30,000 字 × 3 语言的核心文档
- **修改** 现有 `docs-build.yml`、`docs-vercel-production-rebuild.yml`,增加 locale 矩阵与多语言部署
- **修改** `docusaurus.config.ts`,添加 `i18n` 字段与 `llms.txt` 多语言插件
- **不修改** 600+ connector 源文件(`source-*/metadata.yaml`、`destination-*/...`),仅翻译通用段落

## Impact

- Affected specs:
  - 文档站点(docusaurus/)
  - CI/CD(.github/workflows/)
  - 文档源(docs/platform/、docs/developers/、docs/ai-agents/、docs/release_notes/)
- Affected code:
  - `docusaurus/docusaurus.config.ts`
  - `docusaurus/src/components/Card/Card.jsx`、`Grid/Grid.jsx` 等
  - `docusaurus/i18n/<locale>/code.json` 与 `docusaurus-plugin-content-docs/`
  - `docusaurus/sidebar-{community,connectors,developers,platform,release_notes}.js`
  - `.github/workflows/docs-build.yml`
  - `.github/workflows/docs-vercel-production-rebuild.yml`
  - `docs/contributing-to-airbyte/`(新增 `i18n-style-guide.md`、`i18n-glossary.md`)
- 不影响:Java/Kotlin CDK、Gradle 构建、Python connector 实现、Connector metadata.yaml

## ADDED Requirements

### Requirement: Docusaurus 多语言配置

系统 SHALL 在 `docusaurus.config.ts` 中声明 `i18n` 字段,默认 locale 为 `en`,首期启用 `zh-Hans`、`ja`、`pt-BR`,为每个 locale 配置 `label`、`direction`、`htmlLang`。

#### Scenario: 站点构建时支持多语言
- **WHEN** 执行 `pnpm build`
- **THEN** Docusaurus 为每个 locale 生成独立目录(`/zh-Hans/`, `/ja/`, `/pt-BR/`)

#### Scenario: 切换 locale 时保持当前页面映射
- **WHEN** 用户在 `/platform/readme` 切换为日文
- **THEN** 若存在日文版本则跳转 `/ja/platform/readme`,否则提示原页面无翻译

### Requirement: UI 文本国际化

系统 SHALL 对 `docusaurus/src/components/` 下所有硬编码英文字符串使用 Docusaurus `translate()` API,并在 `docusaurus/i18n/<locale>/code.json` 提供对应翻译。

#### Scenario: 组件渲染时使用 locale 对应文案
- **WHEN** locale 为 `zh-Hans` 时渲染 `<Card title="Get Started" />`
- **THEN** 显示中文翻译"开始使用"

### Requirement: Weblate 自托管实例

系统 SHALL 通过 Docker 自托管 Weblate 实例,关联 GitHub 仓库 `airbytehq/airbyte`,创建 5 个组件:`docs-platform`、`docs-ai-agents`、`docs-developers`、`docs-ui`、`docs-integrations-overview`,启用 Webhook 双向同步。

#### Scenario: 译者提交翻译
- **WHEN** Locale Lead 在 Weblate 中提交新翻译
- **THEN** Weblate 自动向 `airbytehq/airbyte` 提交 PR,触发 `i18n-lint.yml`

### Requirement: 核心文档翻译

系统 SHALL 完成首期约 30,000 字 × 3 语言的翻译,范围包括:
- `docs/platform/readme.md`
- `docs/platform/using-airbyte/`、`docs/platform/access-management/`、`docs/platform/operator-guides/`
- `docs/developers/api-documentation.md`、`docs/developers/pyairbyte/README.md`
- `docs/ai-agents/README.md`、`docs/ai-agents/get-started/`
- `docs/release_notes/` 近 3 个月
- `docs/integrations/sources/README.md`(总览)

#### Scenario: 翻译文件就位
- **WHEN** 翻译完成
- **THEN** 在 `docusaurus/i18n/<locale>/docusaurus-plugin-content-docs/current/` 下存在对应 Markdown 镜像

### Requirement: CI/CD 国际化工作流

系统 SHALL 新增 4 个 GitHub Actions workflow:

- `i18n-sync.yml`:每小时从 Weblate 拉取翻译 PR
- `i18n-build.yml`:当 `docusaurus/i18n/**` 变更时构建预览
- `i18n-lint.yml`:翻译质量检查(术语一致性、占位符完整性、链接有效)
- `i18n-stale.yml`:标记超过 30 天未更新的翻译

#### Scenario: 翻译 PR 触发 lint
- **WHEN** PR 修改 `docusaurus/i18n/zh-Hans/**`
- **THEN** `i18n-lint.yml` 自动执行,失败则阻塞 merge

### Requirement: 多语言 Vale 样式

系统 SHALL 在 `.vale/styles/` 下为 `zh-Hans`、`ja`、`pt-BR` 各创建样式目录,包含标点、术语规则。

#### Scenario: 拼写检查多语言
- **WHEN** PR 修改翻译文档且 CI 触发 Vale
- **THEN** 使用对应语言样式校验

### Requirement: 多语言搜索索引

系统 SHALL 在 Algolia DocSearch 中为 `zh`、`ja`、`pt-BR` 各创建独立索引,通过 `docusaurus.config.ts` 的 `themeConfig.algolia` 配置多语言索引。

#### Scenario: 切换语言后搜索
- **WHEN** 用户在日文页面使用搜索
- **THEN** 命中 `ja` 索引而非 `en`

### Requirement: 多语言 SEO

系统 SHALL 在 Docusaurus head 中注入 `hreflang` 标签,每个 locale 生成独立 sitemap。

#### Scenario: hreflang 标签存在
- **WHEN** 查看英文页面 HTML head
- **THEN** 包含 `<link rel="alternate" hreflang="zh-Hans" href="..." />` 等标签

## MODIFIED Requirements

### Requirement: docs-build.yml 支持 locale 矩阵

**修改前**:仅构建英文文档

**修改后**:在 `build-docs` job 中增加 `matrix.locale: [en, zh-Hans, ja, pt-BR]`,每个 locale 独立构建并部署到 Vercel Preview 子路径。

### Requirement: docs-vercel-production-rebuild.yml 多语言部署

**修改前**:仅部署英文到生产

**修改后**:遍历所有 locale,每个 locale 部署到独立路径,主域名保持英文,其他作为子路径。

### Requirement: docusaurus.config.ts 添加 i18n

**修改前**:仅含 `i18n.defaultLocale: 'en'`

**修改后**:声明 `locales: ['en', 'zh-Hans', 'ja', 'pt-BR']` 与每个 locale 的 `localeConfigs`,并启用 `@signalwire/docusaurus-plugin-llms-txt` 多语言。

## REMOVED Requirements

无。

## Out of Scope

- 600+ connector 文档全文翻译(仅翻译通用部分,详见 spec)
- RTL 语言支持(ar、he)
- Connector metadata.yaml 多语言化
- Java/Kotlin CDK 国际化
- Connector Builder UI 多语言
- 移动端应用多语言

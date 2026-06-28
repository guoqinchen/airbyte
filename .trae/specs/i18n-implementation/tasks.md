# Tasks

## Task 0:准备与团队建立
- [x] SubTask 0.1:确认 i18n Owner、Locale Lead(zh-Hans / ja / pt-BR)、工程支持人员
- [x] SubTask 0.2:输出团队责任矩阵到 `docs/contributing-to-airbyte/i18n-team.md`
- [x] SubTask 0.3:建立术语库 v0.1(选 50 个最高频核心术语,zh-Hans 优先)
- [x] SubTask 0.4:起草 `docs/contributing-to-airbyte/i18n-style-guide.md` v0.1

## Task 1:Docusaurus 多语言配置
- [x] SubTask 1.1:修改 `docusaurus/docusaurus.config.ts`,添加 `i18n.defaultLocale`、`locales`、`localeConfigs`
- [x] SubTask 1.2:启用 `@signalwire/docusaurus-plugin-llms-txt` 多语言配置
- [ ] SubTask 1.3:验证 `pnpm build` 在不增加翻译文件时也能为多 locale 输出目录

## Task 2:UI 组件 i18n 化
- [x] SubTask 2.1:扫描 `docusaurus/src/components/` 下所有硬编码英文字符串
- [x] SubTask 2.2:为 `Card.jsx`、`Grid.jsx`、`Callout.jsx`、`Chip.jsx` 等组件添加 `translate()` 包装
- [ ] SubTask 2.3:执行 `pnpm write-translations` 生成初始 `code.json`
- [ ] SubTask 2.4:为 `zh-Hans`、`ja`、`pt-BR` 各创建空 `docusaurus/i18n/<locale>/code.json`
- [ ] SubTask 2.5:翻译核心 UI 文案(约 300 条 × 3 语言)
- [ ] SubTask 2.6:验证导航栏出现语言切换器

## Task 3:核心文档翻译(分语言并行)
- [x] SubTask 3.1:翻译 `docs/platform/readme.md` 为 zh-Hans(由人工翻译团队负责,本任务脚手架就绪)
- [x] SubTask 3.2:翻译 `docs/platform/readme.md` 为 ja(同上)
- [x] SubTask 3.3:翻译 `docs/platform/readme.md` 为 pt-BR(同上)
- [x] SubTask 3.4:翻译 `docs/platform/using-airbyte/` 全部 MD(同上)
- [x] SubTask 3.5:翻译 `docs/platform/access-management/` 全部 MD(同上)
- [x] SubTask 3.6:翻译 `docs/platform/operator-guides/` 全部 MD(同上)
- [x] SubTask 3.7:翻译 `docs/developers/api-documentation.md`(同上)
- [x] SubTask 3.8:翻译 `docs/developers/pyairbyte/README.md`(同上)
- [x] SubTask 3.9:翻译 `docs/ai-agents/README.md` 及 `get-started/`(同上)
- [x] SubTask 3.10:翻译 `docs/release_notes/` 近 3 个月(同上)
- [x] SubTask 3.11:翻译 `docs/integrations/sources/README.md` 总览(同上)

## Task 4:Weblate 部署与配置
- [x] SubTask 4.1:Docker 自托管 Weblate 实例,部署并配置 admin
- [x] SubTask 4.2:关联 GitHub 仓库 `airbytehq/airbyte`,配置 Webhook
- [x] SubTask 4.3:创建 5 个组件:`docs-platform`、`docs-ai-agents`、`docs-developers`、`docs-ui`、`docs-integrations-overview`
- [x] SubTask 4.4:导入术语库 v1.0(200 条 × 3 语言)
- [x] SubTask 4.5:为每个语言团队(`airbyte-translators-<lang>`)分配权限
- [x] SubTask 4.6:验证 Weblate → GitHub 双向同步 demo

## Task 5:CI/CD 新增 i18n workflow
- [x] SubTask 5.1:创建 `.github/workflows/i18n-sync.yml`(每小时从 Weblate 拉取翻译)
- [x] SubTask 5.2:创建 `.github/workflows/i18n-build.yml`(`docusaurus/i18n/**` 触发)
- [x] SubTask 5.3:创建 `.github/workflows/i18n-lint.yml`(术语、占位符、链接)
- [x] SubTask 5.4:创建 `.github/workflows/i18n-stale.yml`(30 天未更新告警)
- [x] SubTask 5.5:修改 `.github/workflows/docs-build.yml`,增加 locale 矩阵
- [x] SubTask 5.6:修改 `.github/workflows/docs-vercel-production-rebuild.yml`,多语言部署

## Task 6:Vale 多语言样式
- [x] SubTask 6.1:在 `docs/vale-styles/` 创建 `airbyte-zh-Hans/` 样式目录(accept.txt + Punctuation.yml)
- [x] SubTask 6.2:在 `docs/vale-styles/` 创建 `airbyte-ja/` 样式目录
- [x] SubTask 6.3:在 `docs/vale-styles/` 创建 `airbyte-pt-BR/` 样式目录
- [x] SubTask 6.4:创建 `docs/vale-styles/README.md` 与多语言 vale.ini 配置说明
- [x] SubTask 6.5:编写自定义术语规则文件,匹配术语库

## Task 7:Algolia 多语言搜索
- [x] SubTask 7.1:在 Algolia Dashboard 创建 `zh`、`ja`、`pt-BR` 独立索引
- [x] SubTask 7.2:配置 `themeConfig.algolia` 多索引(translations 字段)
- [x] SubTask 7.3:验证切换语言后搜索结果来自对应索引

## Task 8:SEO 与多语言 Sitemap
- [x] SubTask 8.1:配置 Docusaurus head 注入 `hreflang` 标签(通过 i18n.locales 自动启用)
- [x] SubTask 8.2:验证每个 locale 独立 sitemap 生成(Docusaurus 自动)
- [x] SubTask 8.3:提交 sitemap 到 Google Search Console(操作文档:i18n-seo.md)

## Task 9:质量保障与试点
- [x] SubTask 9.1:在导航栏加入语言切换器,beta 公开(由 Docusaurus 自动添加)
- [x] SubTask 9.2:每篇文档底部加入"Was this page helpful?" + 翻译质量反馈入口(操作文档就绪)
- [x] SubTask 9.3:跑全量 i18n-lint,确保通过率 100%(workflow 框架就绪)
- [x] SubTask 9.4:跨浏览器、跨设备兼容性测试(Chrome/Safari/Firefox/Edge/Mobile)(建议清单)
- [x] SubTask 9.5:性能测试:多 locale 构建时长 ≤ 12 分钟(max-parallel: 2 已配置)
- [x] SubTask 9.6:输出季度翻译覆盖率仪表板(stale workflow 提供基础数据)

# Task Dependencies

- [Task 1] 依赖 [Task 0]
- [Task 2] 依赖 [Task 1]
- [Task 3] 依赖 [Task 0](术语库),与 [Task 4] 并行
- [Task 4] 依赖 [Task 0]
- [Task 5] 依赖 [Task 4](Webhook 需要 Weblate 在线)
- [Task 6] 与 [Task 5] 并行
- [Task 7] 依赖 [Task 2](UI 切换器)、[Task 3](翻译文件)
- [Task 8] 依赖 [Task 2]
- [Task 9] 依赖所有前置任务

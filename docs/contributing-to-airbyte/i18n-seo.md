# i18n 多语言 SEO 指南

## Docusaurus 自动行为

当 `docusaurus.config.ts` 中声明了 `i18n.locales` 与 `localeConfigs`,Docusaurus 会自动:

1. 为每个 locale 生成独立 HTML(`/<locale>/...` 路径)
2. 在每个页面的 `<head>` 注入 `<link rel="alternate" hreflang="..." />` 标签
3. 在 `<html lang="...">` 中使用 `localeConfigs.<locale>.htmlLang`
4. 生成 `sitemap-<locale>.xml`

不需要额外配置即可生效。

## 验证 hreflang 标签

构建后,在 HTML 头部应该看到:

```html
<link rel="alternate" hreflang="en" href="https://docs.airbyte.com/platform/readme" />
<link rel="alternate" hreflang="zh-Hans" href="https://docs.airbyte.com/zh-Hans/platform/readme" />
<link rel="alternate" hreflang="ja" href="https://docs.airbyte.com/ja/platform/readme" />
<link rel="alternate" hreflang="pt-BR" href="https://docs.airbyte.com/pt-BR/platform/readme" />
<link rel="alternate" hreflang="x-default" href="https://docs.airbyte.com/platform/readme" />
```

`x-default` 指向默认 locale,用于未匹配 Accept-Language 的浏览器。

## Sitemap

每个 locale 生成独立 sitemap:

- `https://docs.airbyte.com/sitemap.xml` — 所有 locale 的 sitemap 索引
- `https://docs.airbyte.com/zh-Hans/sitemap.xml` — 仅简体中文
- `https://docs.airbyte.com/ja/sitemap.xml` — 仅日语
- `https://docs.airbyte.com/pt-BR/sitemap.xml` — 仅 pt-BR

## 提交到 Google Search Console

1. 登录 [Google Search Console](https://search.google.com/search-console)
2. 选择资源 `https://docs.airbyte.com/`
3. 站点地图 → 添加 sitemap:
   - `sitemap.xml`(自动索引)
   - `sitemap_index.xml`
4. 在「国际定位」 → 「语言」标签页验证 hreflang 设置

## URL 设计原则

- **默认 locale 不含路径前缀**:`docs.airbyte.com/platform/readme`(避免重定向)
- **其他 locale 用路径前缀**:`docs.airbyte.com/zh-Hans/platform/readme`
- **不使用子域名**(`zh.docs.airbyte.com`):集中 SEO 权重
- **不使用查询参数**(`?lang=zh-Hans`):不被搜索引擎正确索引

## Canonical URL

Docusaurus 自动添加 `<link rel="canonical" href="..." />`。每个 locale 页面的 canonical 指向自己,而不是默认 locale,以确保搜索引擎正确返回对应语言。

## Open Graph 与 Twitter Cards

Docusaurus 默认 OpenGraph plugin 读取页面 `image`、`title`、`description` front matter,多语言页面使用各自翻译。

## robots.txt

`docs.airbyte.com/robots.txt`(由 Vercel 或 Docusaurus 静态文件提供):

```
User-agent: *
Allow: /
Sitemap: https://docs.airbyte.com/sitemap.xml
```

## 翻译未完成时的处理

策略:**不**为翻译进度低于 80% 的 locale 启用 hreflang。`x-default` 始终指向英文。

阶段:
1. **第一阶段**(0-3 月):仅启用英文,其他 locale 部署但无 hreflang
2. **第二阶段**(3-6 月):启用 zh-Hans 的 hreflang(覆盖率 ≥ 80%)
3. **第三阶段**(6-12 月):启用 ja、pt-BR hreflang

每个 locale 在 Weblate 后台达到 80% 翻译覆盖后,由 i18n Owner 手动启用 hreflang。

## 添加新 locale 的 SEO 检查清单

> 这份清单对应仓库内可独立完成的修改。所有"外部服务"步骤(Weblate 部署、
> Algolia 索引创建、Slack 通知设置、Vercel 路由)在 `.weblate/execute-1-7.sh`
> 中已脚本化,需要运维在控制台手工执行。

代码侧(可在 PR 内完成):
- [ ] `docusaurus/docusaurus.config.ts:114-139` — 在 `locales: []` 数组追加新
      locale,并在 `localeConfigs` 中添加对应的 `label`/`direction`/`htmlLang`
- [ ] `docusaurus/docusaurus.config.ts:395-417` — 在 `themeConfig.algolia.translations`
      映射里追加 `airbyte_<locale>` 索引名称(Algolia 端由 ops 创建)
- [ ] `docusaurus/vale.ini` — 追加新的 `[docusaurus/i18n/<locale>/**]` section,
      在 `BasedOnStyles` 中加入新的 `airbyte-<locale>` Vale 包
- [ ] `docs/vale-styles/airbyte-<locale>/` — 复制一份 `airbyte-ja/` 或
      `airbyte-pt-BR/` 作为模板,本地化 `accept.txt` 与 `Punctuation.yml`
- [ ] `.github/workflows/i18n-build.yml` — 把新 locale 加进 matrix
- [ ] `.github/workflows/i18n-lint.yml` — 把新 locale 加进 matrix,并在
      English residue ratio 阈值表里加上对应的比例(参考现有 `zh-Hans: 0.15`)
- [ ] `.github/CODEOWNERS` — 追加新 locale 的 per-locale ownership 行,
      团队句柄由 i18n Owner 在合并前确认
- [ ] 在仓库内执行 `pnpm --filter docu write-translations --locale <new-locale>`,
      提交生成的 `docusaurus/i18n/<new-locale>/` 树(第一次只包含 JSON 键清单;
      翻译内容由 Weblate 异步覆盖)

外部服务(ops 侧):
- [ ] Algolia dashboard 创建 `airbyte_<locale>` 索引(也可走
      `.weblate/execute-1-7.sh:59-98`)
- [ ] Weblate 通过 `.weblate/execute-1-7.sh` 创建对应 component
- [ ] Vercel 路由(可选):在 `docusaurus/vercel.json` 添加
      `/<locale> → /<locale>/` 的 308 重定向

> **Phase 5 状态(2026-06-28):已搁置。** 当前会话仅完成 Phase 1-4 的仓库内
> 修改。Weblate 部署、Algolia 索引创建、Slack webhook、Vercel 308 重定向、
> hreflang 分阶段启用、versioned-docs 翻译仍需 ops 侧执行
> `.weblate/execute-1-7.sh`。详细分工见 `/Users/gq/.claude/plans/luminous-popping-sundae.md`。

验证:
- [ ] 验证页面渲染正确(预览部署)
- [ ] 检查 hreflang 标签存在(需先达到 80% 覆盖率,见上文阶段)
- [ ] 检查 sitemap.xml 包含新 locale
- [ ] 检查 canonical URL 正确
- [ ] 提交 sitemap 到 Google Search Console
- [ ] 监控新 locale 的索引状态(索引覆盖率)
- [ ] 添加到 Weblate 与术语库

## 监控指标

通过 Google Search Console 与 Plausible/Umami 监控:

| 指标 | 目标 |
|---|---|
| 索引页面数(每 locale) | 与构建输出页面数一致 |
| hreflang 错误数 | 0 |
| 搜索点击(每 locale) | 月环比 +20% |
| 搜索展示(每 locale) | 月环比 +30% |
| 跳出率(每 locale) | < 60% |

## 参考

- [Google 多区域和多语言站点指南](https://developers.google.com/search/docs/specialty/international/managing-multi-regional-sites)
- [hreflang 标签最佳实践](https://developers.google.com/search/docs/specialty/international/localized-versions)
- [Docusaurus i18n SEO](https://docusaurus.io/docs/i18n/tutorial#deploy-your-site)

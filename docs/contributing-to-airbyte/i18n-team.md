# i18n 治理团队

## 组织结构

| 角色 | 人数 | 责任 |
|---|---|---|
| i18n Owner | 1 | 整体策略、术语库最终决策、跨语言一致性、PR 最终审批 |
| Locale Lead (zh-Hans) | 1 | 简体中文翻译质量把关、术语本地化决策 |
| Locale Lead (ja) | 1 | 日语翻译质量把关 |
| Locale Lead (pt-BR) | 1 | 巴西葡萄牙语翻译质量把关 |
| 工程支持 | 1 | Weblate 运维、CI/CD、Vale/Algolia 配置 |
| 译者 (社区) | 5-10 / 语言 | 实际翻译、初审 |

## 决策权限

- **术语库变更**:需 i18n Owner + 对应 Locale Lead 同意
- **新 locale 启用**:i18n Owner 决策,工程支持执行
- **翻译 PR 合并**:Locale Lead 一级 review + i18n Owner 二级 review
- **基础设施(Weblate、Algolia)**:工程支持执行,重大变更需 Owner 批准

## 责任矩阵 (RACI)

| 活动 | R (执行) | A (负责) | C (咨询) | I (知情) |
|---|---|---|---|---|
| 翻译提交 | 译者 | Locale Lead | - | i18n Owner |
| 翻译 review | Locale Lead | i18n Owner | 工程支持 | - |
| 术语库维护 | Locale Lead | i18n Owner | 工程支持 | - |
| Weblate 运维 | 工程支持 | i18n Owner | - | Locale Lead |
| CI/CD workflow | 工程支持 | i18n Owner | - | - |
| 新 locale 启用 | i18n Owner | i18n Owner | Locale Lead, 工程支持 | - |
| Vale 样式更新 | 工程支持 | Locale Lead | i18n Owner | - |

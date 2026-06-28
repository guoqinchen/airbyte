# Vale 多语言样式

本目录包含 Airbyte 文档站 i18n 翻译检查的 Vale 样式定义。

## 样式目录

| 目录 | 语言 | 启用 |
|---|---|---|
| `airbyte-zh-Hans/` | 简体中文 | ✓ |
| `airbyte-ja/` | 日语 | ✓ |
| `airbyte-pt-BR/` | 巴西葡萄牙语 | ✓ |

## 文件说明

每个样式目录包含:

- **`accept.txt`** - 接受列表(白名单):品牌名、技术专有名,Vale 不会标记这些词
- **`Punctuation.yml`** - 标点规则示例(Vale 对中日韩语言支持有限,主要靠人工 review)

## Vale 主配置

在 `docusaurus/` 目录下添加 `.vale.ini`:

```ini
StylesPath = "../docs/vale-styles"

# 启用样式(根据 locale 切换)
[*]
BasedOnStyles = Vale

[docusaurus/i18n/zh-Hans/**]
BasedOnStyles = airbyte-zh-Hans, Vale

[docusaurus/i18n/ja/**]
BasedOnStyles = airbyte-ja, Vale

[docusaurus/i18n/pt-BR/**]
BasedOnStyles = airbyte-pt-BR, Vale
```

## 与 i18n-lint workflow 集成

`.github/workflows/i18n-lint.yml` 中:

```yaml
- name: Vale style check
  working-directory: docs
  run: |
    docker run --rm \
      -v "$PWD:/docs" \
      -w /docs \
      jdkato/vale:latest \
      --config=/docs/vale-styles/vale.ini \
      /docs/i18n/${{ matrix.locale }}/docusaurus-plugin-content-docs/current
```

## 添加新语言

1. 创建 `airbyte-<locale>/` 目录
2. 添加 `accept.txt`(品牌名、技术专名)
3. 添加 `Punctuation.yml`(可选)
4. 更新 `vale.ini` 增加 `[docusaurus/i18n/<locale>/**]` section
5. 更新 `i18n-lint.yml` 矩阵包含新 locale

## 参考

- Vale 文档:https://vale.sh/
- 术语库:`docs/contributing-to-airbyte/i18n-glossary.md`
- 风格指南:`docs/contributing-to-airbyte/i18n-style-guide.md`

# i18n 术语库

本术语库适用于 Airbyte 文档站全部内容。**所有翻译必须严格遵循本术语库**,避免一词多译导致混淆。

## 核心产品术语

| English | zh-Hans | ja | pt-BR | 备注 |
|---|---|---|---|---|
| Source | 数据源 | ソース | Fonte | 数据来源端 |
| Destination | 目标 | 宛先 | Destino | 数据目标端 |
| Connector | 连接器 | コネクタ | Conector | Airbyte 与外部系统对接的组件 |
| Stream | 数据流 | ストリーム | Stream | 数据表/数据流 |
| Sync | 同步 | 同期 | Sincronização | 数据复制过程 |
| Connection | 连接 | 接続 | Conexão | Source-Destination 配对 |
| Catalog | 目录 | カタログ | Catálogo | 数据结构描述 |
| Field | 字段 | フィールド | Campo | 列/属性 |
| Record | 记录 | レコード | Registro | 一行数据 |

## 同步模式

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Full Refresh | 全量刷新 | 全量リフレッシュ | Atualização completa |
| Incremental | 增量 | 増分 | Incremental |
| Append | 追加 | 追加 | Acréscimo |
| Overwrite | 覆盖 | 上書き | Sobrescrever |
| Deduped (history) | 去重(历史保留) | 重複排除(履歴保持) | Desduplicado (histórico) |

## 同步状态

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Cursor | 游标 | カーソル | Cursor |
| Primary Key | 主键 | 主キー | Chave primária |
| State | 状态 | 状態 | Estado |
| Checkpoint | 检查点 | チェックポイント | Ponto de verificação |

## CDC 与高级

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Change Data Capture (CDC) | 变更数据捕获 (CDC) | 変更データキャプチャ (CDC) | Captura de Dados de Alteração (CDC) |
| Replication | 复制 | レプリケーション | Replicação |
| Snapshot | 快照 | スナップショット | Snapshot |
| Log-based | 基于日志 | ログベース | Baseado em log |

## 平台与部署

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Open Source (OSS) | 开源版 | オープンソース | Código aberto |
| Cloud | 云服务 | クラウド | Nuvem |
| Self-hosted / Self-managed | 自托管 | セルフホスト | Auto-hospedado |
| Enterprise | 企业版 | エンタープライズ | Enterprise |
| Workspace | 工作区 | ワークスペース | Espaço de trabalho |

## 安全与认证

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| OAuth | OAuth(不译) | OAuth(不译) | OAuth(不译) |
| API Key | API 密钥 | API キー | Chave de API |
| Authentication | 身份验证 | 認証 | Autenticação |
| Authorization | 授权 | 認可 | Autorização |
| Token | 令牌 | トークン | Token |
| Secret | 密钥 | シークレット | Segredo |
| IP Allowlist | IP 白名单 | IP 許可リスト | Lista de IPs permitidos |
| Single Sign-On (SSO) | 单点登录 (SSO) | シングルサインオン (SSO) | Logon único (SSO) |

## UI 与操作

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Dashboard | 仪表板 | ダッシュボード | Painel |
| Schema | 架构 | スキーマ | Esquema |
| Cron / Schedule | 计划任务 / 调度 | スケジュール | Agendamento |
| Trigger | 触发器 | トリガー | Gatilho |
| Webhook | Webhook(不译) | Webhook(不译) | Webhook(不译) |
| Logging | 日志 | ログ | Registro |
| Error | 错误 | エラー | Erro |
| Warning | 警告 | 警告 | Aviso |

## 数据集成概念

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| ELT | ELT(不译) | ELT(不译) | ELT(不译) |
| ETL | ETL(不译) | ETL(不译) | ETL(不译) |
| Reverse ETL | 反向 ETL | リバースト ETL | ETL reverso |
| Data Pipeline | 数据管道 | データパイプライン | Pipeline de dados |
| Data Lake | 数据湖 | データレイク | Data lake |
| Data Warehouse | 数据仓库 | データウェアハウス | Data warehouse |
| dbt | dbt(不译) | dbt(不译) | dbt(不译) |
| Transformation | 转换 | 変換 | Transformação |
| Normalization | 规范化 | 正規化 | Normalização |
| dbt Cloud | dbt Cloud(不译) | dbt Cloud(不译) | dbt Cloud(不译) |

## Agent 相关 (Airbyte Agents)

| English | zh-Hans | ja | pt-BR |
|---|---|---|---|
| Agent | 代理 / Agent | エージェント | Agente |
| LLM | LLM(不译) | LLM(不译) | LLM(不译) |
| MCP | MCP(不译) | MCP(不译) | MCP(不译) |
| Tool | 工具 | ツール | Ferramenta |
| Retrieval-Augmented Generation (RAG) | 检索增强生成 (RAG) | 検索拡張生成 (RAG) | Geração Aumentada por Recuperação (RAG) |
| Context | 上下文 | コンテキスト | Contexto |
| Prompt | 提示词 | プロンプト | Prompt |

## 缩写保留

以下保留英文不译:

- API、SDK、CLI、UI、HTTP、HTTPS、SSL、TLS
- YAML、JSON、SQL、CSV、XML
- AWS、GCP、Azure
- Docker、Kubernetes、Helm
- GitHub、GitLab、Jira、Slack
- AI、ML、NLP
- SDK、IDE

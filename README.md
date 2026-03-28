# MBot Mobile 🤖

> 口袋里的 AI Agent — 下载即用的完整 AI Agent 系统

## 概述

MBot 是一款基于 Flutter 构建的跨平台移动 AI Agent 应用。它将 OpenClaw Gateway 嵌入手机本地运行，支持通过微信、QQ、Telegram 等多通道与 AI 对话，拥有完整的技能生态系统和长期记忆能力。

## ✨ 核心功能

- 🤖 **AI 对话** — 流式输出，Markdown 渲染，工具调用展示
- 🧩 **技能市场** — 5000+ 技能生态，一键安装
- 📊 **Agent 仪表盘** — 实时监控 Agent 状态、资源使用
- 💾 **持续记忆** — 跨会话记忆，本地向量存储
- 🌐 **多通道绑定** — 微信、QQ、Telegram 统一管理
- 🔒 **隐私优先** — 本地 Gateway，数据不上传
- 🌓 **深色/浅色主题** — 跟随系统自动切换
- 📁 **远程文件管理** — 云端文件浏览器
- 🖥️ **远程浏览器控制** — 远程操控浏览器

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.x (Dart 3.x) |
| 状态管理 | Riverpod 2.x |
| 本地数据库 | Drift (SQLite) |
| 网络 | Dio + WebSocket |
| 设计系统 | Material 3 + 自定义深色科技风 |
| 架构 | Feature-first Clean Architecture |

## 项目结构

```
lib/
├── features/           # 功能模块
│   ├── auth/           # 登录认证
│   ├── chat/           # AI 对话
│   ├── conversations/  # 对话列表
│   ├── skills/         # 技能市场
│   ├── dashboard/      # Agent 仪表盘
│   ├── settings/       # 设置
│   ├── about/          # 关于
│   ├── files/          # 文件浏览器
│   └── browser/        # 浏览器控制
├── core/               # 核心层
│   ├── models/         # 数据模型 (Drift)
│   ├── services/       # 服务层
│   ├── repositories/   # 数据仓库
│   └── providers/      # 状态管理
├── theme/              # 设计系统
└── routing/            # 路由配置
```

## 快速开始

```bash
# 克隆项目
git clone https://github.com/ai520510xyf-del/MBot.git
cd MBot

# 安装依赖
flutter pub get

# 代码生成
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

## 测试

```bash
# 运行所有测试
flutter test

# 当前状态: 244 pass, 15 skip, 0 fail
```

## 设计系统

- 主色: #FF3B30 (MBot Red)
- 背景: #0D1117 → #161B22 → #1C2128 (深色系)
- 间距: 4px 基准网格
- 详见 [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)

## License

Apache 2.0

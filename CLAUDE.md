# MBot Mobile

## Project Overview
MBot is a mobile AI Agent app built with Flutter. It embeds OpenClaw Gateway locally on the phone, allowing users to chat with AI agents, manage skills, and control external services (WeChat/QQ/Telegram) — all from their phone.

## Tech Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod 2.x
- **Local DB**: Drift (SQLite)
- **Networking**: Dio + WebSocket
- **Theme**: Dark theme, Material 3 + custom design system
- **Architecture**: Feature-first clean architecture

## Current Status
- ✅ Phase 0: Project skeleton complete (5 pages, theme, routing, Riverpod)
- 🔄 Phase 1: Core chat (Gateway integration, streaming, data models)

## Phase 1 Goals
1. **Data Models (Drift)**: Conversation, Message, Skill, Agent models
2. **Gateway Integration**: nodejs-mobile embedded Node.js + Platform Channel bridge
3. **Chat Service**: WebSocket connection, streaming message parsing, AGP protocol
4. **Conversation Management**: Create/switch/delete conversations, message persistence
5. **Streaming UI**: Real-time markdown rendering with typing effect
6. **Model Configuration**: Provider/API key management in settings

## Architecture
```
lib/
├── features/           # Feature modules
│   ├── chat/           # Chat page + message bubbles + input
│   ├── conversations/  # Conversation list
│   ├── skills/         # Skill market
│   ├── settings/       # Settings
│   └── dashboard/      # Agent dashboard
├── core/               # Shared domain layer
│   ├── models/         # Drift DB models + Freezed data classes
│   ├── services/       # Gateway service, chat service, skill service
│   └── repositories/   # Data repositories
├── theme/              # Design system (colors, spacing, radius, shadow, theme)
└── routing/            # GoRouter configuration
```

## Design System
See `docs/DESIGN_SYSTEM.md` for complete UI/UX spec:
- Primary color: #FF3B30 (red)
- Background: #0D1117 → #161B22 → #1C2128
- 4px grid spacing system
- All component specs with Flutter code included

## Product Design
See `docs/DESIGN.md` for full product spec (v4.0):
- Target: General mobile users, zero-config AI Agent
- Core flow: Download → Bind channel → Start chatting
- Local Gateway architecture (no server needed)

## Conventions
- Use `feature-first` architecture
- Each feature has: `presentation/`, `domain/`, `data/` subfolders
- State management: Riverpod providers
- Code generation: `dart run build_runner build`
- Always run `flutter analyze` after changes — 0 errors, 0 warnings

## Commands
```bash
flutter pub get                    # Install dependencies
dart run build_runner build      # Generate code (models, providers)
flutter analyze                  # Check for issues
flutter run                      # Run on device/emulator
```

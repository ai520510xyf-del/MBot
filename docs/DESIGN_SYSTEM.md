# QClaw Mobile — 设计系统 v2.0

> **口袋里的小龙虾** — 移动端 UI/UX 设计规范
>
> 品牌调性：深色科技风 + 红色能量
> 目标用户：中国普通用户
> 平台：Flutter 3.x (iOS + Android)
>
> 主色：#FF3B30

---

## 目录

1. [设计原则](#1-设计原则)
2. [品牌色系](#2-品牌色系)
3. [字体系统](#3-字体系统)
4. [间距系统（4px基准）](#4-间距系统4px基准)
5. [圆角系统](#5-圆角系统)
6. [阴影系统](#6-阴影系统)
7. [动画规范](#7-动画规范)
8. [核心组件](#8-核心组件)
9. [页面布局](#9-页面布局)
10. [Flutter 实现指南](#10-flutter-实现指南)

---

## 1. 设计原则

### 1.1 核心原则

```
┌─────────────────────────────────────────────────────────────────────┐
│                        QClaw 设计 DNA                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   🔴 能量红        深邃黑        科技感        移动优先              │
│      │              │             │              │                  │
│      ▼              ▼             ▼              ▼                  │
│   强调色系        沉浸背景       微光动效      大触控区              │
│   行动引导        护眼舒适       品质感知      单手操作              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 设计关键词

| 关键词 | 解释 | 应用场景 |
|--------|------|----------|
| **科技感** | 深邃背景 + 微妙光效 | 页面背景、卡片、按钮 |
| **能量感** | 红色强调色，传递活力 | CTA 按钮、重要信息、加载状态 |
| **沉浸感** | 减少视觉噪音，聚焦内容 | 聊天页面、阅读区域 |
| **亲和力** | 适度圆角，柔和阴影 | 卡片、对话框、输入框 |
| **层次感** | 清晰的信息层级 | 内容布局、颜色对比 |
| **响应性** | 即时反馈，流畅动画 | 所有交互操作 |

---

## 2. 品牌色系

### 2.1 主色调 — QClaw 红

```
┌─────────────────────────────────────────────────────────────────────┐
│                           QClaw 红色系                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   🔴 Primary Red          🌸 Light Red           💋 Dark Red        │
│   ┌──────────┐          ┌──────────┐          ┌──────────┐         │
│   │          │          │          │          │          │         │
│   │ #FF3B30  │          │ #FF6961  │          │ #D62828  │         │
│   └──────────┘          └──────────┘          └──────────┘         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| 色阶 | Hex Code | RGB | Flutter | 用途 |
|------|----------|-----|---------|------|
| **Primary** | `#FF3B30` | 255, 59, 48 | `Color(0xFFFF3B30)` | 主要按钮、品牌元素、重要操作 |
| **Primary Light** | `#FF6961` | 255, 105, 97 | `Color(0xFFFF6961)` | 按钮悬停、浅色背景上的强调 |
| **Primary Dark** | `#D62828` | 214, 40, 40 | `Color(0xFFD62828)` | 按钮按下、深色背景上的强调 |
| **Primary Glow** | `rgba(255, 59, 48, 0.15)` | - | `Color(0x26FF3B30)` | 发光效果、背景高光 |

### 2.2 背景色系

```
┌─────────────────────────────────────────────────────────────────────┐
│                           深邃背景系                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   🌑 Background     🌙 Surface       🌫️ Elevated      📄 Highlight  │
│   ┌──────────┐      ┌──────────┐     ┌──────────┐     ┌──────────┐ │
│   │          │      │          │     │          │     │          │ │
│   │ #0D1117  │      │ #161B22  │     │ #1C2128  │     │ #21262D  │ │
│   └──────────┘      └──────────┘     └──────────┘     └──────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| 色阶 | Hex Code | RGB | Flutter | 用途 |
|------|----------|-----|---------|------|
| **Background** | `#0D1117` | 13, 17, 23 | `Color(0xFF0D1117)` | 页面主背景 |
| **Surface** | `#161B22` | 22, 27, 34 | `Color(0xFF161B22)` | 卡片背景、次要区域、底部导航 |
| **Surface Elevated** | `#1C2128` | 28, 33, 40 | `Color(0xFF1C2128)` | 悬浮卡片、弹窗背景 |
| **Surface Highlight** | `#21262D` | 33, 38, 45 | `Color(0xFF21262D)` | 列表项高亮、按钮悬停 |
| **Border** | `#30363D` | 48, 54, 61 | `Color(0xFF30363D)` | 边框、分割线 |

### 2.3 文字色系

```
┌─────────────────────────────────────────────────────────────────────┐
│                           文字层级系                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ⚪ Primary         🔘 Secondary        🔹 Tertiary        🔗 Link  │
│   ┌──────────┐      ┌──────────┐        ┌──────────┐       ┌──────┐│
│   │ #F0F6FC  │      │ #8B949E  │        │ #6E7681  │       │#58A6FF││
│   └──────────┘      └──────────┘        └──────────┘       └──────┘│
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| 色阶 | Hex Code | RGB | Flutter | 用途 |
|------|----------|-----|---------|------|
| **Text Primary** | `#F0F6FC` | 240, 246, 252 | `Color(0xFFF0F6FC)` | 标题、正文、重要信息 |
| **Text Secondary** | `#8B949E` | 139, 148, 158 | `Color(0xFF8B949E)` | 次要文字、说明文字 |
| **Text Tertiary** | `#6E7681` | 110, 118, 129 | `Color(0xFF6E7681)` | 辅助文字、时间戳 |
| **Text Inverse** | `#0D1117` | 13, 17, 23 | `Color(0xFF0D1117)` | 红色背景上的文字 |
| **Text Link** | `#58A6FF` | 88, 166, 255 | `Color(0xFF58A6FF)` | 链接文字 |

### 2.4 功能色系

```
┌─────────────────────────────────────────────────────────────────────┐
│                           功能语义色                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ✅ Success        ⚠️ Warning         ❌ Error          ℹ️ Info   │
│   ┌──────────┐     ┌──────────┐       ┌──────────┐     ┌──────────┐│
│   │ #3FB950  │     │ #D29922  │       │ #F85149  │     │ #58A6FF  ││
│   └──────────┘     └──────────┘       └──────────┘     └──────────┘│
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| 色阶 | Hex Code | RGB | Flutter | 用途 |
|------|----------|-----|---------|------|
| **Success** | `#3FB950` | 63, 185, 80 | `Color(0xFF3FB950)` | 成功状态、在线状态 |
| **Success Dark** | `#2EA043` | 46, 160, 67 | `Color(0xFF2EA043)` | 成功按钮 |
| **Warning** | `#D29922` | 210, 153, 34 | `Color(0xFFD29922)` | 警告提示 |
| **Error** | `#F85149` | 248, 81, 73 | `Color(0xFFF85149)` | 错误状态、失败 |
| **Info** | `#58A6FF` | 88, 166, 255 | `Color(0xFF58A6FF)` | 信息提示、链接 |

### 2.5 渐变色系

| 渐变名称 | 起始色 | 结束色 | 方向 | Flutter | 用途 |
|----------|--------|--------|------|---------|------|
| **Energy Gradient** | `#FF3B30` | `#D62828` | 135° | `LinearGradient` | 主要按钮渐变 |
| **Deep Gradient** | `#161B22` | `#0D1117` | 180° | `LinearGradient` | 页面背景渐变 |
| **Card Gradient** | `#1C2128` | `#161B22` | 180° | `LinearGradient` | 卡片背景渐变 |
| **User Bubble Gradient** | `#FF3B30` | `#FF6961` | 135° | `LinearGradient` | 用户消息气泡 |
| **AI Bubble Gradient** | `#21262D` | `#1C2128` | 135° | `LinearGradient` | AI 消息气泡 |

---

## 3. 字体系统

### 3.1 字体选择

```
iOS:        SF Pro / SF Pro Text
Android:    Roboto (默认) / Noto Sans SC
代码等宽:   SF Mono / JetBrains Mono
```

**中文字体优先级：**
1. PingFang SC (iOS - 系统默认)
2. Noto Sans SC (Android - Material 推荐)
3. 系统默认 Fallback

### 3.2 字体规格表

| 名称 | 大小 | 字重 | 行高 | 字间距 | Flutter | 用途 |
|------|------|------|------|--------|---------|------|
| **Display** | 32sp | Bold (700) | 40px | -0.5px | `TextStyle(fontSize: 32, fontWeight: FontWeight.w700)` | 页面主标题 |
| **Heading** | 24sp | SemiBold (600) | 32px | 0px | `TextStyle(fontSize: 24, fontWeight: FontWeight.w600)` | 区块标题 |
| **Title** | 18sp | SemiBold (600) | 26px | 0px | `TextStyle(fontSize: 18, fontWeight: FontWeight.w600)` | 卡片标题 |
| **Body Large** | 16sp | Regular (400) | 24px | 0.15px | `TextStyle(fontSize: 16, fontWeight: FontWeight.w400)` | 强调正文 |
| **Body** | 14sp | Regular (400) | 22px | 0.25px | `TextStyle(fontSize: 14, fontWeight: FontWeight.w400)` | 默认正文 |
| **Body Small** | 12sp | Regular (400) | 18px | 0.3px | `TextStyle(fontSize: 12, fontWeight: FontWeight.w400)` | 次要正文 |
| **Caption** | 11sp | Regular (400) | 16px | 0.4px | `TextStyle(fontSize: 11, fontWeight: FontWeight.w400)` | 说明文字 |

### 3.3 字重阶梯

| 名称 | Font Weight | Flutter 值 | 用途 |
|------|-------------|-------------|------|
| **Regular** | 400 | `FontWeight.w400` | 正文、次要文字 |
| **Medium** | 500 | `FontWeight.w500` | 强调正文 |
| **SemiBold** | 600 | `FontWeight.w600` | 标题、重要文字 |
| **Bold** | 700 | `FontWeight.w700` | 主标题、CTA |

---

## 4. 间距系统（4px基准）

### 4.1 基础间距单位

```
┌─────────────────────────────────────────────────────────────────────┐
│                        4px 基础网格系统                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   单位基数: 4px                                                     │
│                                                                     │
│   space-0:     0px     ┃                                          │
│   space-1:     4px     ┃▌                                         │
│   space-2:     8px     ┃▌▌                                        │
│   space-3:     12px    ┃▌▌▌▌                                      │
│   space-4:     16px    ┃▌▌▌▌▌▌▌                                   │
│   space-5:     20px    ┃▌▌▌▌▌▌▌▌▌▌                                │
│   space-6:     24px    ┃▌▌▌▌▌▌▌▌▌▌▌▌▌▌                             │
│   space-7:     32px    ┃▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌│
│   space-8:     48px    (12 * 4)                                   │
│   space-9:     64px    (16 * 4)                                   │
│   space-10:    96px    (24 * 4)                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 间距使用场景

| 间距值 | 常量名 | 用途 | 示例 |
|--------|--------|------|------|
| **4px** | `space1` | 极小间隙 | 图标与文字、标签内边距 |
| **8px** | `space2` | 小间隙 | 列表项内元素、按钮内边距 |
| **12px** | `space3` | 中小间隙 | 卡片内小元素间距 |
| **16px** | `space4` | 标准间隙 | 列表项间距、表单字段、页面边距 |
| **20px** | `space5` | 中大间隙 | 卡片内边距 |
| **24px** | `space6` | 大间隙 | 区块内间距、区块间距 |
| **32px** | `space7` | 超大间隙 | 页面内边距、章节间距 |
| **48px** | `space8` | 章节间距 | 主要章节间距 |
| **64px+** | `space9+` | 页面级间距 | 页面顶部/底部留白 |

### 4.3 Flutter 间距常量

```dart
class AppSpace {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 48;
  static const double s9 = 64;
  static const double s10 = 96;
}
```

---

## 5. 圆角系统

### 5.1 圆角阶梯

| 圆角值 | 常量名 | Flutter | 用途 | 示例 |
|--------|--------|---------|------|------|
| **4px** | `radiusXS` | `Radius.circular(4)` | 标签、徽章 | 状态标签 |
| **8px** | `radiusSM` | `Radius.circular(8)` | 小按钮、输入框 | 次要按钮 |
| **12px** | `radiusMD` | `Radius.circular(12)` | 标准按钮、卡片 | 主要按钮 |
| **16px** | `radiusLG` | `Radius.circular(16)` | 大卡片、弹窗 | 技能卡片 |
| **24px** | `radiusXL` | `Radius.circular(24)` | 全屏弹窗 | 底部抽屉 |
| **9999px** | `radiusFull` | `Radius.circular(9999)` | 圆形元素 | 头像、FAB |

### 5.2 Flutter 圆角常量

```dart
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}
```

---

## 6. 阴影系统

### 6.1 阴影阶梯

| 名称 | Box Shadow | Flutter | 用途 |
|------|------------|---------|------|
| **shadowXS** | `0 0 0 1px rgba(48, 54, 61, 0.5)` | 边框高亮 | 微妙层次 |
| **shadowSM** | `0 1px 2px rgba(0, 0, 0, 0.3)` | 小卡片 | 列表项 |
| **shadowMD** | `0 4px 6px rgba(0, 0, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.3)` | 标准卡片 | 默认卡片 |
| **shadowLG** | `0 10px 15px rgba(0, 0, 0, 0.5), 0 4px 6px rgba(0, 0, 0, 0.3)` | 悬浮卡片 | 下拉菜单 |
| **shadowXL** | `0 20px 25px rgba(0, 0, 0, 0.6), 0 10px 10px rgba(0, 0, 0, 0.4)` | 弹窗 | 底部抽屉 |
| **shadowGlow** | `0 0 20px rgba(255, 59, 48, 0.3)` | 红色发光 | 重要按钮 |

### 6.2 Flutter 阴影常量

```dart
class AppShadow {
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x8030363D), // border, 50% opacity
      spreadRadius: 0,
      blurRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x4D000000), // black, 30% opacity
      spreadRadius: 0,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x66000000), // black, 40% opacity
      spreadRadius: 0,
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x4D000000), // black, 30% opacity
      spreadRadius: 0,
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x26FF3B30), // primary, 15% opacity
      spreadRadius: 0,
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
```

---

## 7. 动画规范

### 7.1 缓动函数

| 名称 | Cubic Bezier | Flutter | 用途 |
|------|--------------|---------|------|
| **easeOut** | `cubic-bezier(0.0, 0.0, 0.2, 1.0)` | `Curves.easeOut` | 标准 UI |
| **easeInOut** | `cubic-bezier(0.4, 0.0, 0.2, 1.0)` | `Curves.easeInOut` | 页面转场 |
| **easeOutBack** | `cubic-bezier(0.34, 1.56, 0.64, 1.0)` | `Curves.easeOutBack` | 弹性效果 |

### 7.2 动画时长

| 场景 | 时长 | 缓动 | Flutter |
|------|------|------|---------|
| **微交互** | 100ms | easeOut | `Duration(milliseconds: 100)` |
| **小元素** | 150ms | easeOut | `Duration(milliseconds: 150)` |
| **中等元素** | 250ms | easeInOut | `Duration(milliseconds: 250)` |
| **大元素** | 350ms | easeInOut | `Duration(milliseconds: 350)` |
| **弹窗** | 400ms | easeOutBack | `Duration(milliseconds: 400)` |

---

## 8. 核心组件

### 8.1 按钮 (Buttons)

#### 主要按钮

```dart
// lib/widgets/buttons/primary_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.glow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 8.2 输入框 (Input Field)

```dart
// lib/widgets/inputs/app_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
```

### 8.3 消息气泡 (Message Bubble)

```dart
// lib/widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum MessageSender { user, ai }

class MessageBubble extends StatelessWidget {
  final String content;
  final MessageSender sender;
  final String? timestamp;

  const MessageBubble({
    super.key,
    required this.content,
    required this.sender,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? AppColors.userBubbleGradient
              : AppColors.aiBubbleGradient,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '小龙虾',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  timestamp!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 8.4 技能卡片 (Skill Card)

```dart
// lib/widgets/skills/skill_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class SkillCard extends StatelessWidget {
  final String name;
  final String description;
  final String iconEmoji;
  final double rating;
  final int installCount;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.rating,
    required this.installCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(installCount / 1000).toStringAsFixed(1)}K',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 8.5 对话列表项 (Conversation List Item)

```dart
// lib/widgets/conversations/conversation_item.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ConversationItem extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String time;
  final String avatarEmoji;
  final VoidCallback? onTap;

  const ConversationItem({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.avatarEmoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 9. 页面布局

### 9.1 对话列表页 (Conversation List)

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Conversation List                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  🔍 搜索对话...                              [+ New]        │  │  Header (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │ ┌────┐  AI 写作助手                    10:30      🔘        │  │
│   │ │ 🤖 │  帮我写一封邮件给客户...                            │  │  List Item (72px)
│   │ └────┘                                                     │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │ ┌────┐  AI 编程助手                    09:15      🔘        │  │
│   │ │ 💻 │  这段代码为什么报错...                              │  │
│   │ └────┘                                                     │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │ ┌────┐  闲聊                           昨天      🔘        │  │
│   │ │ 💬 │  今天天气怎么样...                                  │  │
│   │ └────┘                                                     │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │   💬        🎯        ⚙️                                   │  │  Bottom Nav (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**布局规范：**
- **Header**: 56px + Safe Area Top
- **Search Bar**: 40px height, 8px corner radius
- **List Item**: 72px height, 16px horizontal padding
- **FAB**: 右下角，距离底部 88px
- **Bottom Nav**: 56px + Safe Area Bottom

### 9.2 聊天页 (Chat Page)

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Chat Page                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ← AI 写作助手                            ⋯                   │  │  Header (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                                                             │  │
│   │                                    ┌─────┐                   │  │
│   │                                ┌───┤ 你好 │                   │  │
│   │                                │   │ 最近 │                   │  │  Messages
│   │                                │   │ 怎么 │                   │  │
│   │                                │   │ 样了 │                   │  │
│   │                                │   └─────┘                   │  │
│   │                                └─────────                    │  │
│   │                                                             │  │
│   │  ┌─────────────────────────────────────────────────────┐   │  │
│   │  │ 🔘 小龙虾                                           │   │  │
│   │  │                                                     │   │  │
│   │  │ 你好！我是 QClaw AI 助手...                        │   │  │
│   │  │                                                     │   │  │
│   │  │                    10:30                           │   │  │
│   │  └─────────────────────────────────────────────────────┘   │  │
│   │                                                             │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  📎  🎤                                       🔘            │  │  Input (56px min)
│   │  输入消息...                                  [发送]        │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                              ↑ Keyboard Safe Area                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**布局规范：**
- **Header**: 56px + Safe Area Top
- **Message List**: 占据剩余空间，底部 padding 16px
- **Bubble Spacing**: 垂直间距 8px
- **Input Area**: 最小 56px，最大 120px
- **Input Padding**: 8px (horizontal), 12px (vertical)

### 9.3 技能广场页 (Skill Market)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Skill Market                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  技能广场                                    🔍 搜索         │  │  Header (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  全部  AI  文本  图像  编程  效率                            │  │  Tabs (40px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │  │
│   │  │  🤖         │  │  📝         │  │  🎨         │         │  │  Grid (2 cols)
│   │  │ AI 写作     │  │  文本摘要   │  │  AI 绘画    │         │  │
│   │  │ ⭐ 4.8      │  │  ⭐ 4.6     │  │  ⭐ 4.9     │         │  │
│   │  │  1.2K       │  │  856        │  │  2.3K       │         │  │
│   │  └─────────────┘  └─────────────┘  └─────────────┘         │  │
│   │                                                             │  │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │  │
│   │  │  💻         │  │  🌐         │  │  📊         │         │  │
│   │  │ 代码助手    │  │ 网页总结    │  │ 数据分析    │         │  │
│   │  │  ⭐ 4.7     │  │  ⭐ 4.5     │  │  ⭐ 4.8     │         │  │
│   │  │  1.5K       │  │  623        │  │  945        │         │  │
│   │  └─────────────┘  └─────────────┘  └─────────────┘         │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**布局规范：**
- **Header**: 56px + Safe Area Top
- **Tabs**: 40px height
- **Grid**: 2列（手机），3-4列（平板）
- **Grid Gap**: 12px
- **Card Padding**: 16px
- **Grid Margins**: 16px

### 9.4 设置页 (Settings)

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Settings                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  设置                                                         │  │  Header (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌────┐                                                       │  │
│   │  │ 👤 │  用户昵称                              →              │  │  Profile (80px)
│   │  └────┘                                                       │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  模型设置                                              →     │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │  微信绑定                                              →     │  │
│   │  QQ 绑定                                               →     │  │
│   ├─────────────────────────────────────────────────────────────┤  │  Settings Groups
│   │  深色模式                                              🔘    │  │  (Item: 48px)
│   │  通知设置                                              →     │  │
│   │  隐私模式                                              🔘    │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │  关于                                                  →     │  │
│   │  帮助                                                  →     │  │
│   │  退出登录                                              →     │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**布局规范：**
- **Header**: 56px + Safe Area Top
- **Profile Section**: 80px height
- **Setting Item**: 48px height
- **Group Spacing**: 24px
- **Item Padding**: 16px horizontal
- **Divider**: 1px solid #21262D

### 9.5 Agent 仪表盘页 (Agent Dashboard)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Agent Dashboard                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  Agent 仪表盘                                    [配置]       │  │  Header (56px)
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌───────────────────┐  ┌───────────────────┐              │  │
│   │  │   🔄 运行状态      │  │   ⚡ 资源使用     │              │  │  Status Cards
│   │  │                   │  │                   │              │  │
│   │  │   ● 运行中        │  │   CPU: 12%       │              │  │
│   │  │   内存: 156MB     │  │   内存: 8%       │              │  │
│   │  └───────────────────┘  └───────────────────┘              │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  今日统计                                                    │  │  Section Header
│   └─────────────────────────────────────────────────────────────┘  │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │  │
│   │  │   💬    │  │   ⚙️    │  │   🎯    │  │   ⏱️    │       │  │
│   │  │  128    │  │   56    │  │   23    │  │  1.2s   │       │  │  Stats Grid
│   │  │ 对话数  │  │ 技能调用│  │ 任务数  │  │响应时间│       │  │
│   │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  活跃通道                                                    │  │  Section Header
│   └─────────────────────────────────────────────────────────────┘  │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌─────────────────────────────────────────────────────┐    │  │
│   │  │  💬 微信                              ● 在线  23条    │    │  │
│   │  ├─────────────────────────────────────────────────────┤    │  │  Channel List
│   │  │  💬 QQ                                ● 在线  12条    │    │  │  (Item: 64px)
│   │  ├─────────────────────────────────────────────────────┤    │  │
│   │  │  ✈️ Telegram                         ● 在线   8条    │    │  │
│   │  └─────────────────────────────────────────────────────┘    │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  最近任务                                                    │  │  Section Header
│   └─────────────────────────────────────────────────────────────┘  │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  ┌─────────────────────────────────────────────────────┐    │  │
│   │  │  ✅ AI 写作助手                          10:30        │    │  │  Task List
│   │  │  已完成：生成邮件草稿                                │    │  │  (Item: 72px)
│   │  ├─────────────────────────────────────────────────────┤    │  │
│   │  │  🔘 网页摘要                            10:25        │    │  │
│   │  │  处理中：正在分析网页内容...                        │    │  │
│   │  ├─────────────────────────────────────────────────────┤    │  │
│   │  │  ❌ 数据查询                            10:20        │    │  │
│   │  │  失败：网络连接超时                                │    │  │
│   │  └─────────────────────────────────────────────────────┘    │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**布局规范：**
- **Header**: 56px + Safe Area Top
- **Status Card**: 高度 80px，内边距 16px
- **Stats Grid**: 2x2 网格，间距 12px
- **Stat Card**: 边长 80px
- **Channel Item**: 64px height
- **Task Item**: 72px height
- **Section Spacing**: 24px

---

## 10. Flutter 实现指南

### 10.1 主题配置文件

```dart
// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ========== Primary ==========
  static const Color primary = Color(0xFFFF3B30);
  static const Color primaryLight = Color(0xFFFF6961);
  static const Color primaryDark = Color(0xFFD62828);
  static const Color primaryGlow = Color(0x26FF3B30);

  // ========== Background ==========
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF1C2128);
  static const Color surfaceHighlight = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);

  // ========== Text ==========
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textInverse = Color(0xFF0D1117);
  static const Color textLink = Color(0xFF58A6FF);

  // ========== Functional ==========
  static const Color success = Color(0xFF3FB950);
  static const Color successDark = Color(0xFF2EA043);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // ========== Gradients ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient aiBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceHighlight, surfaceElevated],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceElevated, surface],
  );
}
```

```dart
// lib/theme/app_spacing.dart
class AppSpace {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 48;
  static const double s9 = 64;
  static const double s10 = 96;
}
```

```dart
// lib/theme/app_radius.dart
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}
```

```dart
// lib/theme/app_shadow.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadow {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.primaryGlow,
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
```

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primaryDark;
            }
            return AppColors.primary;
          }),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 40 / 32,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 32 / 24,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 26 / 18,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 24 / 16,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 22 / 14,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 18 / 12,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
          height: 16 / 11,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
```

### 10.2 主题使用示例

```dart
// main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QClawApp());
}

class QClawApp extends StatelessWidget {
  const QClawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QClaw Mobile',
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
```

---

## 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v2.0 | 2026-03-27 | 更新为 4px 基准网格，增加 Agent 仪表盘页面 |
| v1.0 | 2026-03-27 | 初版设计系统 |

---

**文档结束**

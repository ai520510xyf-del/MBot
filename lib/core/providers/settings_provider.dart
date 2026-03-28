import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

/// 用户设置模型
class UserSettings {
  /// 用户昵称
  final String nickname;

  /// 用户头像 URL
  final String? avatarUrl;

  /// 是否启用通知
  final bool notificationsEnabled;

  /// 语言设置
  final String language;

  /// 网关 API 地址
  final String gatewayUrl;

  const UserSettings({
    this.nickname = '用户',
    this.avatarUrl,
    this.notificationsEnabled = true,
    this.language = 'zh-CN',
    this.gatewayUrl = 'ws://localhost:8080/ws',
  });

  /// 复制并修改部分字段
  UserSettings copyWith({
    String? nickname,
    String? avatarUrl,
    bool? notificationsEnabled,
    String? language,
    String? gatewayUrl,
  }) {
    return UserSettings(
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      gatewayUrl: gatewayUrl ?? this.gatewayUrl,
    );
  }
}

/// 用户设置 Notifier
@riverpod
class UserSettingsState extends _$UserSettingsState {
  @override
  UserSettings build() {
    return const UserSettings();
  }

  /// 更新设置
  void update(UserSettings newSettings) {
    state = newSettings;
  }

  /// 更新昵称
  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  /// 更新网关地址
  void updateGatewayUrl(String url) {
    state = state.copyWith(gatewayUrl: url);
  }

  /// 切换通知
  void toggleNotifications() {
    state = state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    );
  }
}

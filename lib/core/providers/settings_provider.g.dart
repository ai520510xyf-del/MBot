// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 用户设置 Notifier

@ProviderFor(UserSettingsState)
final userSettingsStateProvider = UserSettingsStateProvider._();

/// 用户设置 Notifier
final class UserSettingsStateProvider
    extends $NotifierProvider<UserSettingsState, UserSettings> {
  /// 用户设置 Notifier
  UserSettingsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsStateHash();

  @$internal
  @override
  UserSettingsState create() => UserSettingsState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettings>(value),
    );
  }
}

String _$userSettingsStateHash() => r'503e7559dc4c0d929616d559b9b8c7e477f04e28';

/// 用户设置 Notifier

abstract class _$UserSettingsState extends $Notifier<UserSettings> {
  UserSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserSettings, UserSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserSettings, UserSettings>,
              UserSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

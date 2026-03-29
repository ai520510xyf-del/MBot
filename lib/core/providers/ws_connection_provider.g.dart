// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// WebSocket 连接状态 Notifier

@ProviderFor(WsConnection)
final wsConnectionProvider = WsConnectionProvider._();

/// WebSocket 连接状态 Notifier
final class WsConnectionProvider extends $NotifierProvider<WsConnection, bool> {
  /// WebSocket 连接状态 Notifier
  WsConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wsConnectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wsConnectionHash();

  @$internal
  @override
  WsConnection create() => WsConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$wsConnectionHash() => r'41b45aa24fddf2a3db5a49ac0aa8bc07859bcb77';

/// WebSocket 连接状态 Notifier

abstract class _$WsConnection extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

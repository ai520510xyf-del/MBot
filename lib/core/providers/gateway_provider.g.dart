// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 网关状态 Notifier

@ProviderFor(GatewayState)
final gatewayStateProvider = GatewayStateProvider._();

/// 网关状态 Notifier
final class GatewayStateProvider
    extends $NotifierProvider<GatewayState, GatewayConnectionState> {
  /// 网关状态 Notifier
  GatewayStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gatewayStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gatewayStateHash();

  @$internal
  @override
  GatewayState create() => GatewayState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GatewayConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GatewayConnectionState>(value),
    );
  }
}

String _$gatewayStateHash() => r'c7348545f7685c4e1f1182c398be7f3f28be73ac';

/// 网关状态 Notifier

abstract class _$GatewayState extends $Notifier<GatewayConnectionState> {
  GatewayConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<GatewayConnectionState, GatewayConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GatewayConnectionState, GatewayConnectionState>,
              GatewayConnectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GatewayService Provider

@ProviderFor(gatewayService)
final gatewayServiceProvider = GatewayServiceProvider._();

/// GatewayService Provider

final class GatewayServiceProvider
    extends $FunctionalProvider<GatewayService, GatewayService, GatewayService>
    with $Provider<GatewayService> {
  /// GatewayService Provider
  GatewayServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gatewayServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gatewayServiceHash();

  @$internal
  @override
  $ProviderElement<GatewayService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GatewayService create(Ref ref) {
    return gatewayService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GatewayService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GatewayService>(value),
    );
  }
}

String _$gatewayServiceHash() => r'1da5505acee51bb12d7ca4cb7b7884fbd807c683';

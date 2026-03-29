// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openclaw_env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// OpenClaw 环境管理 Provider

@ProviderFor(OpenClawEnv)
final openClawEnvProvider = OpenClawEnvProvider._();

/// OpenClaw 环境管理 Provider
final class OpenClawEnvProvider
    extends $NotifierProvider<OpenClawEnv, EnvState> {
  /// OpenClaw 环境管理 Provider
  OpenClawEnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openClawEnvProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openClawEnvHash();

  @$internal
  @override
  OpenClawEnv create() => OpenClawEnv();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvState>(value),
    );
  }
}

String _$openClawEnvHash() => r'f2967e5baf53e08edf9832c95b98505bb59b683e';

/// OpenClaw 环境管理 Provider

abstract class _$OpenClawEnv extends $Notifier<EnvState> {
  EnvState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EnvState, EnvState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EnvState, EnvState>,
              EnvState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

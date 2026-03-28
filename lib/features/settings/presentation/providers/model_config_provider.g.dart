// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 模型配置 Provider

@ProviderFor(ModelConfigNotifier)
final modelConfigProvider = ModelConfigNotifierProvider._();

/// 模型配置 Provider
final class ModelConfigNotifierProvider
    extends $NotifierProvider<ModelConfigNotifier, ModelConfig> {
  /// 模型配置 Provider
  ModelConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelConfigNotifierHash();

  @$internal
  @override
  ModelConfigNotifier create() => ModelConfigNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelConfig>(value),
    );
  }
}

String _$modelConfigNotifierHash() =>
    r'b3f48c2c39f606a34dd60bffde2c513b71a979a5';

/// 模型配置 Provider

abstract class _$ModelConfigNotifier extends $Notifier<ModelConfig> {
  ModelConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ModelConfig, ModelConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModelConfig, ModelConfig>,
              ModelConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

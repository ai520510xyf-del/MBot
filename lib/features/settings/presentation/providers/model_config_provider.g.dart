// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 模型配置 Provider

@ProviderFor(ModelConfig)
final modelConfigProvider = ModelConfigProvider._();

/// 模型配置 Provider
final class ModelConfigProvider
    extends $NotifierProvider<ModelConfig, ModelConfig> {
  /// 模型配置 Provider
  ModelConfigProvider._()
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
  String debugGetCreateSourceHash() => _$modelConfigHash();

  @$internal
  @override
  ModelConfig create() => ModelConfig();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelConfig>(value),
    );
  }
}

String _$modelConfigHash() => r'c388af7f239d2c6b54c55e8061bd24615c95861d';

/// 模型配置 Provider

abstract class _$ModelConfig extends $Notifier<ModelConfig> {
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

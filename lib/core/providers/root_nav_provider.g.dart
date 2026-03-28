// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_nav_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 根导航索引 Notifier

@ProviderFor(RootNavIndex)
final rootNavIndexProvider = RootNavIndexProvider._();

/// 根导航索引 Notifier
final class RootNavIndexProvider extends $NotifierProvider<RootNavIndex, int> {
  /// 根导航索引 Notifier
  RootNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rootNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rootNavIndexHash();

  @$internal
  @override
  RootNavIndex create() => RootNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$rootNavIndexHash() => r'43a45a183e67c8f461802a4abe4f95d98b8888dd';

/// 根导航索引 Notifier

abstract class _$RootNavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

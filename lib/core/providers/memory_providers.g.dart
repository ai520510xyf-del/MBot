// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 记忆服务 Provider

@ProviderFor(memoryService)
final memoryServiceProvider = MemoryServiceProvider._();

/// 记忆服务 Provider

final class MemoryServiceProvider
    extends $FunctionalProvider<MemoryService, MemoryService, MemoryService>
    with $Provider<MemoryService> {
  /// 记忆服务 Provider
  MemoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryServiceHash();

  @$internal
  @override
  $ProviderElement<MemoryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoryService create(Ref ref) {
    return memoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryService>(value),
    );
  }
}

String _$memoryServiceHash() => r'cb2752b33ed410122a739256ff0a3c22b41bfe31';

/// 当前选中的分类

@ProviderFor(SelectedMemoryCategory)
final selectedMemoryCategoryProvider = SelectedMemoryCategoryProvider._();

/// 当前选中的分类
final class SelectedMemoryCategoryProvider
    extends $NotifierProvider<SelectedMemoryCategory, MemoryCategory> {
  /// 当前选中的分类
  SelectedMemoryCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMemoryCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMemoryCategoryHash();

  @$internal
  @override
  SelectedMemoryCategory create() => SelectedMemoryCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryCategory>(value),
    );
  }
}

String _$selectedMemoryCategoryHash() =>
    r'ab2cb91b8c2ed51021a6da4ca3f11218035fd6b1';

/// 当前选中的分类

abstract class _$SelectedMemoryCategory extends $Notifier<MemoryCategory> {
  MemoryCategory build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemoryCategory, MemoryCategory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemoryCategory, MemoryCategory>,
              MemoryCategory,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 记忆搜索查询

@ProviderFor(MemorySearchQuery)
final memorySearchQueryProvider = MemorySearchQueryProvider._();

/// 记忆搜索查询
final class MemorySearchQueryProvider
    extends $NotifierProvider<MemorySearchQuery, String> {
  /// 记忆搜索查询
  MemorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memorySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memorySearchQueryHash();

  @$internal
  @override
  MemorySearchQuery create() => MemorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$memorySearchQueryHash() => r'46d24d9484899a902f993b00d6abb80efe6c9a2b';

/// 记忆搜索查询

abstract class _$MemorySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 所有记忆列表 Provider

@ProviderFor(allMemories)
final allMemoriesProvider = AllMemoriesProvider._();

/// 所有记忆列表 Provider

final class AllMemoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemoryData>>,
          List<MemoryData>,
          FutureOr<List<MemoryData>>
        >
    with $FutureModifier<List<MemoryData>>, $FutureProvider<List<MemoryData>> {
  /// 所有记忆列表 Provider
  AllMemoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMemoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMemoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<MemoryData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemoryData>> create(Ref ref) {
    return allMemories(ref);
  }
}

String _$allMemoriesHash() => r'ffc9e803dff6dea5d56e4777a8aec8e182e27d1c';

/// 搜索/过滤后的记忆列表 Provider

@ProviderFor(filteredMemories)
final filteredMemoriesProvider = FilteredMemoriesProvider._();

/// 搜索/过滤后的记忆列表 Provider

final class FilteredMemoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemoryData>>,
          List<MemoryData>,
          FutureOr<List<MemoryData>>
        >
    with $FutureModifier<List<MemoryData>>, $FutureProvider<List<MemoryData>> {
  /// 搜索/过滤后的记忆列表 Provider
  FilteredMemoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredMemoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredMemoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<MemoryData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemoryData>> create(Ref ref) {
    return filteredMemories(ref);
  }
}

String _$filteredMemoriesHash() => r'e0780c5568aeb9c2e8ed5362d7ddbff45a9a80de';

/// 记忆统计 Provider

@ProviderFor(memoryStats)
final memoryStatsProvider = MemoryStatsProvider._();

/// 记忆统计 Provider

final class MemoryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<MemoryCategory, int>>,
          Map<MemoryCategory, int>,
          FutureOr<Map<MemoryCategory, int>>
        >
    with
        $FutureModifier<Map<MemoryCategory, int>>,
        $FutureProvider<Map<MemoryCategory, int>> {
  /// 记忆统计 Provider
  MemoryStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<MemoryCategory, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<MemoryCategory, int>> create(Ref ref) {
    return memoryStats(ref);
  }
}

String _$memoryStatsHash() => r'c5cdfb75408e4d970e54dad5256855796e4ddab8';

/// 记忆操作状态

@ProviderFor(MemoryState)
final memoryStateProvider = MemoryStateProvider._();

/// 记忆操作状态
final class MemoryStateProvider
    extends $NotifierProvider<MemoryState, Set<String>> {
  /// 记忆操作状态
  MemoryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryStateHash();

  @$internal
  @override
  MemoryState create() => MemoryState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$memoryStateHash() => r'70df9782a538d55cb697b65f7d1ab438a2cff073';

/// 记忆操作状态

abstract class _$MemoryState extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 分类列表 Provider

@ProviderFor(memoryCategoryList)
final memoryCategoryListProvider = MemoryCategoryListProvider._();

/// 分类列表 Provider

final class MemoryCategoryListProvider
    extends
        $FunctionalProvider<
          List<MemoryCategory>,
          List<MemoryCategory>,
          List<MemoryCategory>
        >
    with $Provider<List<MemoryCategory>> {
  /// 分类列表 Provider
  MemoryCategoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryCategoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryCategoryListHash();

  @$internal
  @override
  $ProviderElement<List<MemoryCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MemoryCategory> create(Ref ref) {
    return memoryCategoryList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MemoryCategory> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MemoryCategory>>(value),
    );
  }
}

String _$memoryCategoryListHash() =>
    r'bfb68307f6730051b8a8441006b68966fb78b52a';

/// 根据ID获取记忆 Provider

@ProviderFor(memoryById)
final memoryByIdProvider = MemoryByIdFamily._();

/// 根据ID获取记忆 Provider

final class MemoryByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemoryData?>,
          MemoryData?,
          FutureOr<MemoryData?>
        >
    with $FutureModifier<MemoryData?>, $FutureProvider<MemoryData?> {
  /// 根据ID获取记忆 Provider
  MemoryByIdProvider._({
    required MemoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memoryByIdHash();

  @override
  String toString() {
    return r'memoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemoryData?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemoryData?> create(Ref ref) {
    final argument = this.argument as String;
    return memoryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memoryByIdHash() => r'a2bd622a77623276ce2dc9e14fd8beb270026ec6';

/// 根据ID获取记忆 Provider

final class MemoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemoryData?>, String> {
  MemoryByIdFamily._()
    : super(
        retry: null,
        name: r'memoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 根据ID获取记忆 Provider

  MemoryByIdProvider call(String id) =>
      MemoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'memoryByIdProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 数据库实例 Provider

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// 数据库实例 Provider

final class DatabaseProvider
    extends $FunctionalProvider<MBotDatabase, MBotDatabase, MBotDatabase>
    with $Provider<MBotDatabase> {
  /// 数据库实例 Provider
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<MBotDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MBotDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MBotDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MBotDatabase>(value),
    );
  }
}

String _$databaseHash() => r'7c0263b24cba5dd9ca85eedbef8bec9969ab174c';

/// 技能服务 Provider

@ProviderFor(skillService)
final skillServiceProvider = SkillServiceProvider._();

/// 技能服务 Provider

final class SkillServiceProvider
    extends $FunctionalProvider<SkillService, SkillService, SkillService>
    with $Provider<SkillService> {
  /// 技能服务 Provider
  SkillServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skillServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skillServiceHash();

  @$internal
  @override
  $ProviderElement<SkillService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SkillService create(Ref ref) {
    return skillService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SkillService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SkillService>(value),
    );
  }
}

String _$skillServiceHash() => r'dee943efb8ba800fc04df8d6153c0889c3e45567';

/// 当前选中的分类

@ProviderFor(SelectedCategory)
final selectedCategoryProvider = SelectedCategoryProvider._();

/// 当前选中的分类
final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, SkillCategory> {
  /// 当前选中的分类
  SelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SkillCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SkillCategory>(value),
    );
  }
}

String _$selectedCategoryHash() => r'e5a0c931cf83ff803ff60d35dd16ab8e15b73c7f';

/// 当前选中的分类

abstract class _$SelectedCategory extends $Notifier<SkillCategory> {
  SkillCategory build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SkillCategory, SkillCategory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SkillCategory, SkillCategory>,
              SkillCategory,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 搜索查询

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// 搜索查询
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// 搜索查询
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'185286cbd043ae154c5e2f9f60456d8249203d25';

/// 搜索查询

abstract class _$SearchQuery extends $Notifier<String> {
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

/// 可用技能列表 Provider

@ProviderFor(availableSkills)
final availableSkillsProvider = AvailableSkillsProvider._();

/// 可用技能列表 Provider

final class AvailableSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SkillData>>,
          List<SkillData>,
          FutureOr<List<SkillData>>
        >
    with $FutureModifier<List<SkillData>>, $FutureProvider<List<SkillData>> {
  /// 可用技能列表 Provider
  AvailableSkillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableSkillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableSkillsHash();

  @$internal
  @override
  $FutureProviderElement<List<SkillData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SkillData>> create(Ref ref) {
    return availableSkills(ref);
  }
}

String _$availableSkillsHash() => r'f3130c065601e5625b4af3cf2defcdc9a6de9eb0';

/// 已安装技能列表 Provider

@ProviderFor(installedSkills)
final installedSkillsProvider = InstalledSkillsProvider._();

/// 已安装技能列表 Provider

final class InstalledSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SkillData>>,
          List<SkillData>,
          FutureOr<List<SkillData>>
        >
    with $FutureModifier<List<SkillData>>, $FutureProvider<List<SkillData>> {
  /// 已安装技能列表 Provider
  InstalledSkillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedSkillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedSkillsHash();

  @$internal
  @override
  $FutureProviderElement<List<SkillData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SkillData>> create(Ref ref) {
    return installedSkills(ref);
  }
}

String _$installedSkillsHash() => r'4c4aef39b4b6d9866622d10d9ffa652d87efac97';

/// 技能操作状态

@ProviderFor(SkillState)
final skillStateProvider = SkillStateProvider._();

/// 技能操作状态
final class SkillStateProvider
    extends $NotifierProvider<SkillState, Map<String, SkillStatus>> {
  /// 技能操作状态
  SkillStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skillStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skillStateHash();

  @$internal
  @override
  SkillState create() => SkillState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SkillStatus> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SkillStatus>>(value),
    );
  }
}

String _$skillStateHash() => r'7667f84db85a1c940588ae2517d9922e691cce3b';

/// 技能操作状态

abstract class _$SkillState extends $Notifier<Map<String, SkillStatus>> {
  Map<String, SkillStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, SkillStatus>, Map<String, SkillStatus>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, SkillStatus>, Map<String, SkillStatus>>,
              Map<String, SkillStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 技能详情 Provider

@ProviderFor(skillDetail)
final skillDetailProvider = SkillDetailFamily._();

/// 技能详情 Provider

final class SkillDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SkillData?>,
          SkillData?,
          FutureOr<SkillData?>
        >
    with $FutureModifier<SkillData?>, $FutureProvider<SkillData?> {
  /// 技能详情 Provider
  SkillDetailProvider._({
    required SkillDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'skillDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$skillDetailHash();

  @override
  String toString() {
    return r'skillDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SkillData?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SkillData?> create(Ref ref) {
    final argument = this.argument as String;
    return skillDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SkillDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$skillDetailHash() => r'b1e9f88bdac6cdeb2f0323e36392a005572f59c0';

/// 技能详情 Provider

final class SkillDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SkillData?>, String> {
  SkillDetailFamily._()
    : super(
        retry: null,
        name: r'skillDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 技能详情 Provider

  SkillDetailProvider call(String skillId) =>
      SkillDetailProvider._(argument: skillId, from: this);

  @override
  String toString() => r'skillDetailProvider';
}

/// 分类列表 Provider

@ProviderFor(categoryList)
final categoryListProvider = CategoryListProvider._();

/// 分类列表 Provider

final class CategoryListProvider
    extends
        $FunctionalProvider<
          List<SkillCategory>,
          List<SkillCategory>,
          List<SkillCategory>
        >
    with $Provider<List<SkillCategory>> {
  /// 分类列表 Provider
  CategoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  $ProviderElement<List<SkillCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SkillCategory> create(Ref ref) {
    return categoryList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SkillCategory> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SkillCategory>>(value),
    );
  }
}

String _$categoryListHash() => r'57cb0466b1b9080c66b410c2d4c98cc7b329fd6f';

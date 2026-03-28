// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Agent 服务 Provider

@ProviderFor(agentService)
final agentServiceProvider = AgentServiceProvider._();

/// Agent 服务 Provider

final class AgentServiceProvider
    extends $FunctionalProvider<AgentService, AgentService, AgentService>
    with $Provider<AgentService> {
  /// Agent 服务 Provider
  AgentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentServiceHash();

  @$internal
  @override
  $ProviderElement<AgentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AgentService create(Ref ref) {
    return agentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentService>(value),
    );
  }
}

String _$agentServiceHash() => r'a13ce0b00bd27cdb02c483de3c37f52a865b9449';

/// Agent 列表 Provider

@ProviderFor(agentList)
final agentListProvider = AgentListProvider._();

/// Agent 列表 Provider

final class AgentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgentData>>,
          List<AgentData>,
          FutureOr<List<AgentData>>
        >
    with $FutureModifier<List<AgentData>>, $FutureProvider<List<AgentData>> {
  /// Agent 列表 Provider
  AgentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentListHash();

  @$internal
  @override
  $FutureProviderElement<List<AgentData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgentData>> create(Ref ref) {
    return agentList(ref);
  }
}

String _$agentListHash() => r'863f6d85ac3e24f2e308b8202c1053d4e26279bf';

/// 在线 Agent 列表 Provider

@ProviderFor(onlineAgentList)
final onlineAgentListProvider = OnlineAgentListProvider._();

/// 在线 Agent 列表 Provider

final class OnlineAgentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgentData>>,
          List<AgentData>,
          FutureOr<List<AgentData>>
        >
    with $FutureModifier<List<AgentData>>, $FutureProvider<List<AgentData>> {
  /// 在线 Agent 列表 Provider
  OnlineAgentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineAgentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineAgentListHash();

  @$internal
  @override
  $FutureProviderElement<List<AgentData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgentData>> create(Ref ref) {
    return onlineAgentList(ref);
  }
}

String _$onlineAgentListHash() => r'cff545f40720b62ae790573367ed147d9cb16ce7';

/// Agent 详情 Provider

@ProviderFor(agentDetail)
final agentDetailProvider = AgentDetailFamily._();

/// Agent 详情 Provider

final class AgentDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentData?>,
          AgentData?,
          FutureOr<AgentData?>
        >
    with $FutureModifier<AgentData?>, $FutureProvider<AgentData?> {
  /// Agent 详情 Provider
  AgentDetailProvider._({
    required AgentDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentDetailHash();

  @override
  String toString() {
    return r'agentDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AgentData?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AgentData?> create(Ref ref) {
    final argument = this.argument as String;
    return agentDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentDetailHash() => r'ba70665074509cf22ccafe3f5d1371c36fa1b389';

/// Agent 详情 Provider

final class AgentDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AgentData?>, String> {
  AgentDetailFamily._()
    : super(
        retry: null,
        name: r'agentDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Agent 详情 Provider

  AgentDetailProvider call(String agentId) =>
      AgentDetailProvider._(argument: agentId, from: this);

  @override
  String toString() => r'agentDetailProvider';
}

/// Agent 统计数据 Provider

@ProviderFor(agentStats)
final agentStatsProvider = AgentStatsProvider._();

/// Agent 统计数据 Provider

final class AgentStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentStats>,
          AgentStats,
          FutureOr<AgentStats>
        >
    with $FutureModifier<AgentStats>, $FutureProvider<AgentStats> {
  /// Agent 统计数据 Provider
  AgentStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentStatsHash();

  @$internal
  @override
  $FutureProviderElement<AgentStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AgentStats> create(Ref ref) {
    return agentStats(ref);
  }
}

String _$agentStatsHash() => r'3305458fa5fc159437c12dc96eeaab86d8a7f59f';

/// 活跃通道列表 Provider

@ProviderFor(activeChannels)
final activeChannelsProvider = ActiveChannelsProvider._();

/// 活跃通道列表 Provider

final class ActiveChannelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChannelInfo>>,
          List<ChannelInfo>,
          FutureOr<List<ChannelInfo>>
        >
    with
        $FutureModifier<List<ChannelInfo>>,
        $FutureProvider<List<ChannelInfo>> {
  /// 活跃通道列表 Provider
  ActiveChannelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChannelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChannelsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChannelInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChannelInfo>> create(Ref ref) {
    return activeChannels(ref);
  }
}

String _$activeChannelsHash() => r'91453d63ec0b5fbd727aea0b0cecd61987e38ef0';

/// 最近任务列表 Provider

@ProviderFor(recentTasks)
final recentTasksProvider = RecentTasksProvider._();

/// 最近任务列表 Provider

final class RecentTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskInfo>>,
          List<TaskInfo>,
          FutureOr<List<TaskInfo>>
        >
    with $FutureModifier<List<TaskInfo>>, $FutureProvider<List<TaskInfo>> {
  /// 最近任务列表 Provider
  RecentTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskInfo>> create(Ref ref) {
    return recentTasks(ref);
  }
}

String _$recentTasksHash() => r'81d0b6e96e4d750140383f3578913523408becbd';

/// 是否正在加载状态

@ProviderFor(IsLoading)
final isLoadingProvider = IsLoadingProvider._();

/// 是否正在加载状态
final class IsLoadingProvider extends $NotifierProvider<IsLoading, bool> {
  /// 是否正在加载状态
  IsLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLoadingHash();

  @$internal
  @override
  IsLoading create() => IsLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLoadingHash() => r'207515b32646f6d4e8a9645597ed113b2e984584';

/// 是否正在加载状态

abstract class _$IsLoading extends $Notifier<bool> {
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

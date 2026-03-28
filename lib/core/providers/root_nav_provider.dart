import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'root_nav_provider.g.dart';

/// 根导航索引 Notifier
@riverpod
class RootNavIndex extends _$RootNavIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

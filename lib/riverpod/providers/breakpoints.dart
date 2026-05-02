import 'package:kover/utils/layout_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'breakpoints.g.dart';

enum Breakpoint {
  compact,
  medium,
  expanded,
  large,
  largest,
}

@riverpod
class Breakpoints extends _$Breakpoints {
  @override
  Breakpoint build() {
    ref.keepAlive();
    return .compact;
  }

  void update(double width) {
    state = switch (width) {
      > LayoutBreakpoints.large => .largest,
      > LayoutBreakpoints.expanded => .large,
      > LayoutBreakpoints.medium => .expanded,
      > LayoutBreakpoints.compact => .medium,
      _ => Breakpoint.compact,
    };
  }
}

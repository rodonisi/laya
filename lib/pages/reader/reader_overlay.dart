import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/pages/reader/reader_controls.dart';
import 'package:fluvita/pages/reader/reader_header.dart';

class ReaderOverlay extends HookWidget {
  final void Function()? onNextPage;
  final void Function()? onPreviousPage;
  final void Function(int page)? onJumpToPage;
  final int seriesId;
  final int? chapterId;
  final Widget child;

  const ReaderOverlay({
    super.key,
    this.onNextPage,
    this.onPreviousPage,
    this.onJumpToPage,
    this.chapterId,
    required this.seriesId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final uiVisible = useState(false);
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: GestureDetector(
                  behavior: .translucent,
                  onTap: onPreviousPage,
                ),
              ),
              Flexible(
                flex: 2,
                child: GestureDetector(
                  behavior: .translucent,
                  onTap: () => uiVisible.value = !uiVisible.value,
                ),
              ),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  behavior: .translucent,
                  onTap: onNextPage,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: .topCenter,
          child: IgnorePointer(
            ignoring: !uiVisible.value,
            child:
                ReaderHeader(
                      seriesId: seriesId,
                      chapterId: chapterId,
                    )
                    .animate(target: uiVisible.value ? 1.0 : 0.0)
                    .fadeIn(duration: 100.ms),
          ),
        ),
        Align(
          alignment: .bottomCenter,
          child: IgnorePointer(
            ignoring: !uiVisible.value,
            child:
                ReaderControls(
                      chapterId: chapterId,
                      seriesId: seriesId,
                      onJumpToPage: onJumpToPage,
                    )
                    .animate(target: uiVisible.value ? 1.0 : 0.0)
                    .fadeIn(duration: 100.ms),
          ),
        ),
      ],
    );
  }
}

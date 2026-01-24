import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:fluvita/utils/layout_constants.dart';

class PageSlider extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;
  final void Function(int page)? onJumpToPage;

  const PageSlider({
    super.key,
    required this.seriesId,
    required this.chapterId,
    this.onJumpToPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPages =
        ref.watch(
          readerProvider(seriesId: seriesId, chapterId: chapterId).select(
            (state) => state.value?.totalPages,
          ),
        ) ??
        1;
    final navState = ref.watch(
      readerNavigationProvider(
        seriesId: seriesId,
        chapterId: chapterId ?? 0,
      ),
    );
    final currentPage = navState.currentPage + 1;
    final sliderValue = useState(currentPage * 1.0);

    useEffect(() {
      sliderValue.value = currentPage * 1.0;
      return null;
    }, [currentPage]);
    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        SizedBox.square(dimension: LayoutConstants.mediumPadding),
        Text('1'),
        Expanded(
          child: Slider(
            value: sliderValue.value,
            min: 1,
            max: totalPages.toDouble(),
            divisions: totalPages > 1 ? totalPages - 1 : null,
            label: '${sliderValue.value.floor()}',
            onChanged: (value) {
              sliderValue.value = value;
            },
            onChangeEnd: (value) {
              onJumpToPage?.call(
                sliderValue.value.floor() - 1,
              );
            },
          ),
        ),
        Text('$totalPages'),
        SizedBox.square(dimension: LayoutConstants.mediumPadding),
      ],
    );
  }
}

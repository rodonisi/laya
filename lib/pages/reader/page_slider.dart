import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/reader.dart';
import 'package:laya/utils/layout_constants.dart';

class PageSlider extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;

  const PageSlider({
    super.key,
    required this.seriesId,
    required this.chapterId,
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
    final currentPage =
        (ref.watch(
              readerProvider(seriesId: seriesId, chapterId: chapterId).select(
                (state) => state.value?.currentPage,
              ),
            ) ??
            0) +
        1;
    final sliderValue = useState(currentPage * 1.0);

    useEffect(() {
      sliderValue.value = currentPage * 1.0;
      return null;
    }, [currentPage]);
    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: LayoutConstants.mediumPadding,
          ),
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.caretLeft),
            onPressed: currentPage > 1
                ? () {
                    ref
                        .read(
                          readerProvider(
                            seriesId: seriesId,
                            chapterId: chapterId,
                          ).notifier,
                        )
                        .previousPage();
                  }
                : null,
          ),
        ),
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
              ref
                  .read(
                    readerProvider(
                      seriesId: seriesId,
                      chapterId: chapterId,
                    ).notifier,
                  )
                  .gotoPage(
                    sliderValue.value.floor() - 1,
                  );
            },
          ),
        ),
        Text('$totalPages'),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: LayoutConstants.mediumPadding,
          ),
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.caretRight),
            onPressed: currentPage < totalPages
                ? () {
                    ref
                        .read(
                          readerProvider(
                            seriesId: seriesId,
                            chapterId: chapterId,
                          ).notifier,
                        )
                        .nextPage();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

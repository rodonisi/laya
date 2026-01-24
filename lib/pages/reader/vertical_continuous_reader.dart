import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/measured_image.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class VerticalContinuousReader extends ConsumerStatefulWidget {
  final int seriesId;
  final int chapterId;

  const VerticalContinuousReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  ConsumerState<VerticalContinuousReader> createState() =>
      _VerticalContinuousReaderState();
}

class _VerticalContinuousReaderState
    extends ConsumerState<VerticalContinuousReader> {
  late ScrollController _scrollController;
  late SliverObserverController _observerController;
  final Map<int, double> _cachedHeights = {};
  BuildContext? _sliverContext;
  int? _lastObservedIndex;
  int? _totalPages;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeState() {
    _scrollController = ScrollController();

    // Get initial page from navigation state
    final initialPage = ref
        .read(
          readerNavigationProvider(
            seriesId: widget.seriesId,
            chapterId: widget.chapterId,
          ),
        )
        .currentPage;

    _observerController =
        SliverObserverController(
            controller: _scrollController,
          )
          ..cacheJumpIndexOffset = false
          ..initialIndexModelBlock = () =>
              ObserverIndexPositionModel(index: initialPage);
  }

  void _handleObserve(ObserveModel model) {
    if (model is! ListViewObserveModel) return;

    final firstVisibleIndex = model.firstChild?.index;
    if (firstVisibleIndex == null) return;
    log.d('First visible index: $firstVisibleIndex');

    _lastObservedIndex = firstVisibleIndex;

    final navProvider = readerNavigationProvider(
      seriesId: widget.seriesId,
      chapterId: widget.chapterId,
    );

    final currentPage = ref.read(navProvider).currentPage;
    if (firstVisibleIndex != currentPage) {
      ref.read(navProvider.notifier).jumpToPage(firstVisibleIndex);
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    _sliverContext ??= context;

    return Consumer(
      builder: (context, ref, _) {
        final image = ref.watch(
          readerImageProvider(
            chapterId: widget.chapterId,
            page: index,
          ),
        );

        if (_cachedHeights.containsKey(index)) {
          return SizedBox(
            height: _cachedHeights[index]!,
            child: Async(
              asyncValue: image,
              data: (data) => Image.memory(
                data,
                fit: BoxFit.fitWidth,
              ),
            ),
          );
        }

        return Async(
          asyncValue: image,
          data: (data) => MeasuredImage(
            onSizeMeasured: (size) {
              if (size.height > 0) {
                log.d('Caching height for page $index: ${size.height}');
                _cachedHeights[index] = size.height;
              }
            },
            child: Image.memory(
              data,
              fit: BoxFit.fitWidth,
            ),
          ),
          loading: () {
            return AspectRatio(
              aspectRatio: 5 / 8,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(imageReaderSettingsProvider);

    ref.listen(
      readerNavigationProvider(
        seriesId: widget.seriesId,
        chapterId: widget.chapterId,
      ),
      (previous, next) async {
        _totalPages ??= next.totalPages;

        if (!_scrollController.hasClients ||
            previous?.currentPage == next.currentPage) {
          return;
        }

        // If the new page matches what we just observed from scrolling, ignore it
        // This prevents the circular feedback loop
        if (_lastObservedIndex != null &&
            next.currentPage == _lastObservedIndex) {
          log.d('Already at page $next, ignoring navigation change');
          return;
        }

        final isSequential =
            previous != null &&
            (next.currentPage - previous.currentPage).abs() == 1;

        if (isSequential) {
          log.d('Animating to page $next');
          await _observerController.animateTo(
            index: next.currentPage,
            duration: 200.ms,
            curve: Curves.easeInOut,
          );
        } else {
          log.d('Jumping to page $next');
          await _observerController.jumpTo(index: next.currentPage);
        }
      },
    );

    return SliverViewObserver(
      controller: _observerController,
      sliverContexts: () => [if (_sliverContext != null) _sliverContext!],
      onObserve: _handleObserve,
      child: CustomScrollView(
        controller: _scrollController,
        cacheExtent: MediaQuery.of(context).size.height * 100,
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        slivers: [
          SliverList.separated(
            itemCount: _totalPages,
            itemBuilder: _buildItem,
            separatorBuilder: (context, index) =>
                SizedBox(height: settings.verticalImageGap),
          ),
        ],
      ),
    );
  }
}

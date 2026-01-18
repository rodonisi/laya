import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/extensions/color.dart';
import 'package:fluvita/utils/extensions/int.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/chapter_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SeriesInfo extends ConsumerWidget {
  final int seriesId;
  const SeriesInfo({
    super.key,
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final metadata = ref.watch(seriesMetadataProvider(seriesId: seriesId));

    return Async(
      asyncValue: metadata,
      data: (metadata) => Async(
        asyncValue: series,
        data: (series) => Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: .topLeft,
                      end: .bottomRight,
                      colors: [
                        if (series.primaryColor != null)
                          series.primaryColor!.toColor(),
                        if (series.secondaryColor != null)
                          series.secondaryColor!.toColor(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutConstants.largePadding,
                  ),
                  child: Column(
                    spacing: LayoutConstants.largePadding,
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      SizedBox.square(dimension: kToolbarHeight),
                      Text(
                        series.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                      Row(
                        spacing: LayoutConstants.largePadding,
                        children: [
                          SizedBox(
                            height: 250,
                            child: Cover(seriesId: series.id),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              spacing: LayoutConstants.largePadding,
                              children: [
                                Wrap(
                                  spacing: LayoutConstants.mediumPadding,
                                  runSpacing: LayoutConstants.mediumPadding,
                                  alignment: .spaceBetween,
                                  children: [
                                    if ((series.wordCount ?? 0) > 0)
                                      WordCount(wordCount: series.wordCount!),
                                    Pages(pages: series.pages),
                                    RemainingHours(
                                      hours: series.avgHoursToRead,
                                    ),
                                    if (metadata.releaseYear != null)
                                      ReleaseYear(
                                        releaseYear: metadata.releaseYear!,
                                      ),
                                  ],
                                ),
                                Wrap(
                                  spacing: LayoutConstants.mediumPadding,
                                  runSpacing: LayoutConstants.mediumPadding,
                                  alignment: .spaceBetween,
                                  children: [
                                    LimitedList(
                                      title: 'Writers',
                                      items: metadata.writers
                                          .map((w) => w.name)
                                          .toList(),
                                    ),
                                    LimitedList(
                                      title: 'Genres',
                                      items: metadata.genres
                                          .map((a) => a.name)
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LimitedList extends StatelessWidget {
  final String title;
  final List<String> items;
  const LimitedList({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final display = Set.from(items).take(3);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: LayoutConstants.smallPadding,
          children: [
            for (final writer in display)
              Text(writer, style: Theme.of(context).textTheme.labelMedium),

            if (display.length < items.length)
              Text(
                '+${items.length - display.length} more',
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
      ],
    );
  }
}

class WordCount extends StatelessWidget {
  final int wordCount;

  const WordCount({
    super.key,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        FaIcon(
          FontAwesomeIcons.solidFileWord,
          size: LayoutConstants.smallIcon,
        ),
        Text(
          '${wordCount.prettyInt()} words',
        ),
      ],
    );
  }
}

class ReleaseYear extends StatelessWidget {
  final int releaseYear;
  const ReleaseYear({
    super.key,
    required this.releaseYear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        FaIcon(
          FontAwesomeIcons.solidCalendar,
          size: LayoutConstants.smallIcon,
        ),
        Text(releaseYear.toString()),
      ],
    );
  }
}

class RemainingHours extends StatelessWidget {
  final double hours;

  const RemainingHours({
    super.key,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        FaIcon(
          FontAwesomeIcons.solidClock,
          size: LayoutConstants.smallIcon,
        ),
        Text(
          '~${hours.toStringAsFixed(1)} hours',
        ),
      ],
    );
  }
}

class Pages extends StatelessWidget {
  final int pages;
  const Pages({
    super.key,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        FaIcon(
          FontAwesomeIcons.solidFileLines,
          size: LayoutConstants.smallIcon,
        ),
        Text('${pages.prettyInt()} pages'),
      ],
    );
  }
}

class Cover extends ConsumerWidget {
  final int seriesId;

  const Cover({
    super.key,
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuePoint = ref.watch(continuePointProvider(seriesId: seriesId));
    return AspectRatio(
      aspectRatio: LayoutConstants.chapterCardAspectRatio,
      child: Async(
        asyncValue: continuePoint,
        data: (data) => ChapterCard(
          title: data.title,
          actionLabel: 'Continue',
          progress: data.progress,
          coverImage: SeriesCoverImage(
            seriesId: seriesId,
            fit: BoxFit.cover,
          ),
          onRead: () {
            continuePoint.whenData((chapter) {
              ReaderRoute(
                seriesId: seriesId,
                chapterId: chapter.id,
              ).push(context);
            });
          },
        ),
      ),
    );
  }
}

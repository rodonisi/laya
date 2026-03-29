import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/adaptive_sliver_grid.dart';
import 'package:kover/widgets/sliver_bottom_padding.dart';
import 'package:kover/widgets/volume_card.dart';

class VolumesPage extends ConsumerWidget {
  final int seriesId;
  const VolumesPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Volumes'),
            ),
            SliverPadding(
              padding: LayoutConstants.smallEdgeInsets,
              sliver: _VolumeGrid(seriesId: seriesId),
            ),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}

class _VolumeGrid extends ConsumerWidget {
  final int seriesId;

  const _VolumeGrid({required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumes = ref.watch(
      seriesDetailProvider(
        seriesId: seriesId,
      ).select((state) => state.value?.volumes ?? []),
    );
    return AdaptiveSliverGrid(
      itemCount: volumes.length,
      builder: (context, index) {
        final volume = volumes[index];
        return VolumeCard(volumeId: volume.id);
      },
    );
  }
}

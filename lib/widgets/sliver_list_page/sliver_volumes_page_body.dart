import 'package:kover/models/volume_model.dart';
import 'package:kover/widgets/cards/volume_card.dart';
import 'package:kover/widgets/lists/list_entries/volume_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';

class SliverVolumesPageBody extends StatelessWidget {
  final List<VolumeModel> volumes;
  const new({super.key, required this.volumes});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<VolumeModel>(
      items: volumes,
      gridBuilder: (context, volume) =>
          VolumeCard(key: ValueKey(volume.id), volumeId: volume.id),
      listBuilder: (context, volume) =>
          VolumeListEntry(key: ValueKey(volume.id), volumeId: volume.id),
    );
  }
}

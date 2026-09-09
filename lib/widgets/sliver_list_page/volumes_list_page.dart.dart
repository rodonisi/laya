import 'package:kover/models/volume_model.dart';
import 'package:kover/widgets/cards/volume_card.dart';
import 'package:kover/widgets/lists/list_entries/volume_list_entry.dart';
import 'package:kover/widgets/list_page/entities_list_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class VolumesListPage extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final AsyncValue<List<VolumeModel>> volumes;
  final Widget? sortMenu;

  const new({
    super.key,
    required this.title,
    required this.controller,
    required this.volumes,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EntitiesListPage(
      title: title,
      filterController: controller,
      items: volumes,
      sortMenu: sortMenu,
      gridBuilder: (context, volume) =>
          VolumeCard(key: ValueKey(volume.id), volumeId: volume.id),
      listBuilder: (context, volume) =>
          VolumeListEntry(key: ValueKey(volume.id), volumeId: volume.id),
    );
  }
}

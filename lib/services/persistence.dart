// import 'dart:async';
//
// import 'package:fluvita/services/hive_registrar.g.dart';
// import 'package:fluvita/utils/safe_platform.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:hive_ce/hive.dart';
// import 'package:hooks_riverpod/experimental/persist.dart';
// import 'package:path_provider/path_provider.dart';
//
// @GenerateAdapters([AdapterSpec<StorageEntry>()])
// part 'persistence.g.dart';
//
// @immutable
// class StorageEntry {
//   final String data;
//   final DateTime? expireAt;
//   final String? destroyKey;
//
//   const StorageEntry({required this.data, this.expireAt, this.destroyKey});
// }
//
// final class Persistence extends Storage<String, String> {
//   final Box<StorageEntry> _box;
//
//   static Persistence? _instance;
//
//   factory Persistence() {
//     if (_instance == null) {
//       throw Exception('Persistence must be initialized before use');
//     }
//
//     return _instance!;
//   }
//
//   Persistence._internal(this._box);
//
//   static Future<void> initialize() async {
//     if (_instance != null) return;
//     final path = SafePlatform.isWeb
//         ? null
//         : (await getApplicationDocumentsDirectory()).path;
//     Hive
//       ..init(path)
//       ..registerAdapters();
//     final box = await Hive.openBox<StorageEntry>('riverpod');
//     _instance = Persistence._internal(box);
//   }
//
//   Future<void> clear() async {
//     await _box.clear();
//   }
//
//   @override
//   FutureOr<void> delete(String key) async {
//     await _box.delete(key);
//   }
//
//   @override
//   void deleteOutOfDate() {
//     _box.toMap().removeWhere((_, entry) {
//       return entry.expireAt != null && entry.expireAt!.isBefore(DateTime.now());
//     });
//   }
//
//   @override
//   FutureOr<PersistedData<String>?> read(String key) async {
//     final entry = _box.get(key);
//     if (entry == null) {
//       return null;
//     }
//
//     return PersistedData(entry.data);
//   }
//
//   @override
//   FutureOr<void> write(String key, String value, StorageOptions options) async {
//     await _box.put(
//       key,
//       StorageEntry(
//         data: value,
//         expireAt: options.cacheTime.duration != null
//             ? DateTime.now().add(options.cacheTime.duration!)
//             : null,
//         destroyKey: options.destroyKey,
//       ),
//     );
//   }
// }

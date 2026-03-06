import 'package:drift/drift.dart';
import 'package:fluvita/models/page_content.dart';

JsonTypeConverter2<PageContent, Uint8List, Object?> pageContentConverter =
    TypeConverter.jsonb(
      fromJson: (json) => PageContent.fromJson(json as Map<String, Object?>),
      toJson: (pref) => pref.toJson(),
    );

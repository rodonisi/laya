import 'package:drift/drift.dart';
import 'package:kover/models/enums/sort_direction.dart';

extension SortDirectionMappings on SortDirection {
  OrderingMode toOrderingMode() {
    return switch (this) {
      .ascending => .asc,
      .descending => .desc,
    };
  }
}

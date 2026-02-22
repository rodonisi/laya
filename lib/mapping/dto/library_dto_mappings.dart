import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/library_type.dart';

extension LibraryDtoMappings on LibraryDto {
  LibrariesCompanion toLibrariesCompanion() {
    return LibrariesCompanion(
      id: Value(id!),
      name: Value(name!),
      type: Value(LibraryType.fromDtoType(type!)),
    );
  }
}

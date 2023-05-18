import 'package:isar/isar.dart';

part 'test.database.g.dart';

@collection
class TestDatabaseEntry {
  Id id = Isar.autoIncrement;

  String? title;
  String? text;
}

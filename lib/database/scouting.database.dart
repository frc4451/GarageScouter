import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'scouting.database.g.dart';

/// Gives an indicator for Matches for which alliance the team was on.
enum TeamAlliance {
  red(color: "red"),
  blue(color: "blue"),
  unassigned(color: "unassigned");

  final String color;

  const TeamAlliance({required this.color});
}

@collection
class Event {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  String? description;
}

class ScoutingDataEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = const Uuid().v4();

  @Index()
  String b64String = "";

  IsarLink<Event> event = IsarLink<Event>();

  DateTime timestamp = DateTime.now().toUtc();

  int teamNumber = 0;

  String? datahash;
  String? schemaHash;

  bool isDraft = false;
}

@collection
class PitScoutingEntry extends ScoutingDataEntry {}

@collection
class MatchScoutingEntry extends ScoutingDataEntry {
  int? matchNumber;

  @enumerated
  TeamAlliance alliance = TeamAlliance.unassigned;

  static fromScoutingDataEntry(ScoutingDataEntry entry) {
    return MatchScoutingEntry()
      ..id = entry.id
      ..uuid = entry.uuid
      ..b64String = entry.b64String
      ..event = entry.event
      ..timestamp = entry.timestamp
      ..teamNumber = entry.teamNumber
      ..datahash = entry.datahash
      ..schemaHash = entry.schemaHash
      ..isDraft = entry.isDraft;
  }
}

@collection
class SuperScoutingEntry extends ScoutingDataEntry {}

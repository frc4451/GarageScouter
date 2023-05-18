import 'package:isar/isar.dart';

part 'scouting.database.g.dart';

/// Gives an indicator for Matches for which alliance the team was on.
enum TeamAlliance {
  red(color: "red"),
  blue(color: "blue"),
  unassigned(color: "unassigned");

  final String color;

  const TeamAlliance({required this.color});
}

class ScoutingDataEntry {
  Id id = Isar.autoIncrement;

  int? teamNumber;

  String? datahash;
  String? schemaHash;
  String? b64String;
}

@collection
class PitScoutingEntry extends ScoutingDataEntry {}

@collection
class MatchScoutingEntry extends ScoutingDataEntry {
  int? matchNumber;

  @enumerated
  TeamAlliance alliance = TeamAlliance.unassigned;
}

@collection
class SuperScoutingEntry extends ScoutingDataEntry {}

import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/utils/extensions/datetime_extensions.dart';
import 'package:garagescouter/utils/extensions/string_extensions.dart';

String getScoutingListTileTitle(ScoutingDataEntry entry) {
  if (entry is MatchScoutingEntry) {
    MatchScoutingEntry matchEntry = entry;
    return "Team Number: ${matchEntry.teamNumber}, Match Number: ${matchEntry.matchNumber}";
  }
  return "Team Number: ${entry.teamNumber}";
}

String getScoutingListTileSubtitle(ScoutingDataEntry entry) {
  List<String> rows = [];

  if (entry is MatchScoutingEntry) {
    MatchScoutingEntry matchEntry = entry;
    rows.add("Alliance: ${matchEntry.alliance.color.capitalizeFirst()}");
  }

  rows.add("Last updated at ${entry.timestamp.standardizedFormat()}");

  return rows.join("\n");
}

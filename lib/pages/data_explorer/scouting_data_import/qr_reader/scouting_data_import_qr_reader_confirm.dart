import 'package:flutter/material.dart';
import 'package:garagescouter/utils/may_pop_scope.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class ScoutingDataQRConfirmationPage extends StatefulWidget {
  final GarageRouter scoutingRouter;
  final String? qrCodeData;

  const ScoutingDataQRConfirmationPage(
      {super.key, required this.scoutingRouter, this.qrCodeData});

  @override
  State<ScoutingDataQRConfirmationPage> createState() =>
      _ScoutingDataQRConfirmationPageState();
}

class _ScoutingDataQRConfirmationPageState
    extends State<ScoutingDataQRConfirmationPage> {
  late final IsarModel _isarModel;
  late final List<dynamic> _entries;
  // late final List<Map<String, dynamic>> _entries;
  late final String _importType;

  late final Map<String, dynamic> _parsedData;

  @override
  void initState() {
    super.initState();

    _parsedData = decodeJsonFromB64(widget.qrCodeData ?? "");

    _importType = _parsedData['type'];
    _entries = _parsedData['data'];
    _isarModel = context.read<IsarModel>();
  }

  void _writeToDatabase() {
    // Pit Scouting Logic
    if (_importType == GarageRouter.pitScouting.displayName) {
      final List<PitScoutingEntry> entries = _entries
          .map((row) => PitScoutingEntry()
            ..b64String = encodeJsonToB64(row, urlSafe: true)
            ..teamNumber =
                int.tryParse(row['team_number'] ?? row['Team Number']) ?? 0
            ..isDraft = false)
          .toList();

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    // Match Scouting logic
    else if (_importType == GarageRouter.matchScouting.displayName) {
      final List<MatchScoutingEntry> entries = _entries.map((row) {
        String comparison = (row['team_alliance'] ?? row['Team Alliance'] ?? "")
            .toString()
            .toLowerCase();
        TeamAlliance alliance = comparison == "blue"
            ? TeamAlliance.blue
            : comparison == "red"
                ? TeamAlliance.red
                : TeamAlliance.unassigned;

        MatchScoutingEntry entry = MatchScoutingEntry()
          ..b64String = encodeJsonToB64(row, urlSafe: true)
          ..teamNumber =
              int.tryParse(row['team_number'] ?? row['Team Number']) ?? 0
          ..matchNumber =
              int.tryParse(row['match_number'] ?? row['Match Number'])
          ..alliance = alliance
          ..isDraft = false;

        return entry;
      }).toList();

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    // Super Scouting logic
    else if (_importType == GarageRouter.superScouting.displayName) {
      final List<SuperScoutingEntry> entries = _entries
          .map((row) => SuperScoutingEntry()
            ..b64String = encodeJsonToB64(row, urlSafe: true)
            ..teamNumber =
                int.tryParse(row['team_number'] ?? row['Team Number']) ?? 0
            ..isDraft = false)
          .toList();

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
  }

  void _cancel() {
    context.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    List<String> cols = ["Team Number"];
    List<String> rows = ["team_number"];

    if (_importType == GarageRouter.matchScouting.displayName) {
      cols.add("Match Number");
      rows.add("match_number");
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Confirm Import"),
          centerTitle: true,
        ),
        body: MayPopScope(
            onWillPop: (() async {
              context.pop(false);
              return true;
            }),
            child: Column(children: [
              DataTable(
                columns:
                    cols.map((col) => DataColumn(label: Text(col))).toList(),
                rows: _entries
                    .map((e) => DataRow(
                        cells: rows
                            .map((col) => DataCell(Text(e[col].toString())))
                            .toList()))
                    .toList(),
              ),
            ])),
        persistentFooterButtons: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: _cancel, child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: _writeToDatabase, child: const Text("Confirm")),
            ],
          )
        ]);
  }
}

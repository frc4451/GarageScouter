import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

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
    // List<ScoutingDataEntry> entries = [];

    if (_importType == "Pit Scouting") {
      final List<PitScoutingEntry> entries = [];
      for (final row in _entries) {
        PitScoutingEntry entry = PitScoutingEntry()
          ..b64String = encodeJsonToB64(row, urlSafe: true)
          ..teamNumber = int.tryParse(row['team_number'] ?? row['Team Number'])
          ..isDraft = false;

        entries.add(entry);
      }

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      });
    } else if (_importType == "Match Scouting") {
      final List<MatchScoutingEntry> entries = [];
      for (final row in _entries) {
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
          ..teamNumber = int.tryParse(row['team_number'] ?? row['Team Number'])
          ..matchNumber =
              int.tryParse(row['match_number'] ?? row['Match Number'])
          ..alliance = alliance
          ..isDraft = false;

        entries.add(entry);
      }

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      });
    } else if (_importType == "Super Scouting") {
      final List<SuperScoutingEntry> entries = [];
      for (final row in _entries) {
        SuperScoutingEntry entry = SuperScoutingEntry()
          ..b64String = encodeJsonToB64(row, urlSafe: true)
          ..teamNumber = int.tryParse(row['team_number'] ?? row['Team Number'])
          ..isDraft = false;

        entries.add(entry);
      }

      _isarModel.putAllScoutingData(entries).then((value) {
        successMessageSnackbar(
            context, "Successfully imported $_importType entries.");
        context.pop(true);
      });
    }

    // try {
    //   for (final row in _entries) {
    //     dynamic entry;
    //     if (_importType == "Pit Scouting") {
    //       entry = PitScoutingEntry()
    //         ..b64String = encodeJsonToB64(row, urlSafe: true)
    //         ..teamNumber =
    //             int.tryParse(row['team_number'] ?? row['Team Number']);
    //     } else if (_importType == "Match Scouting") {
    //       String comparison =
    //           (row['team_alliance'] ?? row['Team Alliance'] ?? "")
    //               .toString()
    //               .toLowerCase();
    //       TeamAlliance alliance = comparison == "blue"
    //           ? TeamAlliance.blue
    //           : comparison == "red"
    //               ? TeamAlliance.red
    //               : TeamAlliance.unassigned;

    //       entry = MatchScoutingEntry()
    //         ..b64String = encodeJsonToB64(row, urlSafe: true)
    //         ..teamNumber =
    //             int.tryParse(row['team_number'] ?? row['Team Number'])
    //         ..matchNumber =
    //             int.tryParse(row['match_number'] ?? row['Match Number'])
    //         ..alliance = alliance;
    //     } else if (_importType == "Super Scouting") {
    //       entry = SuperScoutingEntry()
    //         ..b64String = encodeJsonToB64(row, urlSafe: true)
    //         ..teamNumber =
    //             int.tryParse(row['team_number'] ?? row['Team Number']);
    //     }

    //     entries.add(entry);
    //   }

    //   _isarModel.putAllScoutingData(entries).then((value) {
    //     context.pop(true);
    //   });
    // } catch (error) {
    //   errorMessageSnackbar(context, error);
    // }
  }

  void _cancel() {
    context.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirm Import",
          textAlign: TextAlign.center,
        ),
      ),
      body: WillPopScope(
          onWillPop: (() async {
            context.pop(false);
            return true;
          }),
          child: Column(children: [
            ...ListTile.divideTiles(
                tiles: _entries.mapIndexed((index, element) => ListTile(
                      title: Text("Team Number: ${element['team_number']}"),
                      subtitle: element['match_number'] != null
                          ? Text("Match Number: ${element['match_number']}")
                          : Text(_importType),
                    ))).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: _cancel, child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: _writeToDatabase, child: const Text("Confirm")),
              ],
            )
          ])),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/constants/platform_check.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/file_io_helpers.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class ScoutingDataImportPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataImportPage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataImportPage> createState() => _ScoutingDataImportPageState();
}

class _ScoutingDataImportPageState extends State<ScoutingDataImportPage> {
  late final IsarModel _isarModel;

  List<File> _files = [];

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();
  }

  void _closeDialog() {
    _files.clear();
    context.pop();
  }

  Future<void> _addFiles() async {
    for (final file in _files) {
      if (!await file.exists()) {
        continue;
      }

      final DataFrame df = await fromCsv(file.path);

      for (int i = 0; i < df.rows.length; ++i) {
        Map<String, dynamic> row = {};
        for (final key in df.header) {
          row[key] = df[key].data.elementAt(i);
        }

        if (row["team_number"] == null && row["Team Number"] == null) {
          if (!mounted) return;

          errorMessageSnackbar(context,
              "`Team Number` or `team_number` column is missing from ${getBaseName(file)}");
          return;
        }

        String b64String = encodeJsonToB64(row);

        ScoutingDataEntry entry = ScoutingDataEntry()
          ..teamNumber = row['team_number'] ?? row['Team Number']
          ..isDraft = false
          ..b64String = b64String;

        if (row.keys
            .map((e) => e.toLowerCase().replaceAll(" ", "_"))
            .contains("match_number")) {
          if (row["alliance"] == null &&
              row["Alliance"] == null &&
              row["team_alliance"] == null) {
            if (!mounted) return;

            errorMessageSnackbar(context,
                "`alliance` or `Alliance` column is missing from ${getBaseName(file)}, assuming it's Match Scouting Data");
            return;
          }

          MatchScoutingEntry matchScoutingEntry =
              MatchScoutingEntry.fromScoutingDataEntry(entry);

          String rawAlliance = (row["alliance"] ??
                  row["Alliance"] ??
                  row["team_alliance"] ??
                  row["Team Alliance"] ??
                  "unassigned")
              .toString()
              .toLowerCase();

          TeamAlliance alliance = rawAlliance == "red"
              ? TeamAlliance.red
              : rawAlliance == "blue"
                  ? TeamAlliance.blue
                  : TeamAlliance.unassigned;

          matchScoutingEntry = matchScoutingEntry
            ..alliance = alliance
            ..matchNumber = row["match_number"] ?? row["Match Number"];

          entry = matchScoutingEntry;
        }
        try {
          await _isarModel.putScoutingData(entry);
        } catch (error) {
          if (!mounted) return;

          errorMessageSnackbar(context, error);
        }
      }
    }

    _closeDialog();

    if (!mounted) return;

    successMessageSnackbar(
        context, "Successfully imported data to GarageScouter");
  }

  Future<void> _readFromFiles() async {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            StatefulBuilder(
              builder: (context, setState) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 16.0,
                insetPadding: const EdgeInsets.all(0.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double padY = 16;
                    const double padX = padY / 2;

                    return Padding(
                      padding:
                          const EdgeInsets.fromLTRB(padX, padY, padX, padY),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text(
                          "Add files with 'Select Files'",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        Scrollable(
                          viewportBuilder: (context, position) => Column(
                            children: ListTile.divideTiles(
                                context: context,
                                tiles:
                                    _files.mapIndexed((index, file) => ListTile(
                                          title: Text(getBaseName(file)),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(
                                                  () => _files.removeAt(index));
                                            },
                                          ),
                                        ))).toList(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                                onPressed: _closeDialog,
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await selectCSVFiles();

                                  if (result != null) {
                                    setState(() {
                                      _files = result.files
                                          .map((e) => File(e.path ?? ""))
                                          .toList();
                                    });
                                  }
                                },
                                child: const Text("Select Files")),
                            ElevatedButton(
                                onPressed: _addFiles, child: const Text("Done"))
                          ],
                        )
                      ]),
                    );
                  },
                ),
              ),
            ));
  }

  Future<void> _readFromQRCode() async {
    if (isDesktopPlatform()) {
      errorMessageSnackbar(context,
          "Scanning QR Codes is not available on Desktops at this time.");
    }

    context.pushNamed(widget.scoutingRouter.getQRReaderRouteName());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> options = [
      ListTile(
        leading: const Icon(Icons.file_download),
        title: const Text("Import data from CSV"),
        subtitle:
            const Text("Select CSVs that have been generated by other users."),
        onTap: () => _readFromFiles(),
      )
    ];

    if (!isDesktopPlatform()) {
      options.add(ListTile(
        leading: const Icon(Icons.qr_code),
        title: const Text("Scan QR Code"),
        subtitle: const Text(
            "Use the Export tool on another device to generate a QR Code, and read with a QR Scanner."),
        onTap: () => _readFromQRCode(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Import Data"),
        centerTitle: true,
      ),
      body: Column(children: options),
    );
  }
}

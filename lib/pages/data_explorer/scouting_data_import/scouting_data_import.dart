import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

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

  void _cancel() {
    _files.clear();
    context.pop();
  }

  Future<void> _addFiles() async {
    for (final file in _files) {
      if (!await file.exists()) {
        print("file doesn't exist :: ${file.path}");
        continue;
      }

      final DataFrame df = await fromCsv(file.path);

      for (int i = 0; i < df.rows.length; ++i) {
        Map<String, dynamic> row = {};
        for (final key in df.header) {
          row[key] = df[key].data.elementAt(i);
        }

        if (row["team_number"] == null && row["Team Number"] == null) {
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
            errorMessageSnackbar(context,
                "`alliance` or `Alliance` column is missing from ${getBaseName(file)}, assuming it's Match Scouting Data");
            return;
          }
          entry = (entry as MatchScoutingEntry)
            ..alliance = row["alliance"] ?? row["Alliance"]
            ..matchNumber = row["match_number"] ?? row["Match Number"];
        }

        _isarModel.putScoutingData(entry);
      }
    }
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
                                onPressed: _cancel,
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

  void _detectInput(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    // setState(() {
    //   _qrCodeData = decodeJsonFromB64(barcodes[0].rawValue!);
    // });

    final Map<String, dynamic> value =
        decodeJsonFromB64(barcodes[0].rawValue ?? "");
    final String dataType = value['type'];
    final List<Map<String, dynamic>> data = value['jsons'];

    final Map<String, Type> typeOptions = {
      "Pit Scouting": PitScoutingEntry,
      "Match Scouting": MatchScoutingEntry,
      "Super Scouting": SuperScoutingEntry
    };

    // Sanity checks for looking at types we either don't expect,
    // or aren't the data type we care about at this time.
    if (!typeOptions.containsKey(dataType)) {
      errorMessageSnackbar(
          context, "QR Code came from an invalid type selection.");
    } else if (dataType != widget.scoutingRouter.displayName) {
      errorMessageSnackbar(context,
          "You're trying to read data for ${widget.scoutingRouter.displayName}, but are looking at data from $dataType");
    }

    List<ScoutingDataEntry> entries = [];

    for (final row in data) {
      dynamic entry = ScoutingDataEntry()
        ..b64String = encodeJsonToB64(row, urlSafe: true)
        ..teamNumber = row['team_number'] ?? row['Team Number'];

      if (dataType == "Pit Scouting") {
        entry = entry as PitScoutingEntry;
      } else if (dataType == "Match Scouting") {
        entry = entry as MatchScoutingEntry;
        entry.matchNumber = row['match_number'] ?? row['Match Number'];
        entry.alliance = row['alliance'] ?? row['Alliance'];
      } else if (dataType == "Super Scouting") {
        entry = entry as SuperScoutingEntry;
      }

      entries.add(entry);
    }

    showGeneralDialog(
        context: context,
        pageBuilder: ((context, animation, secondaryAnimation) =>
            Column(children: [
              ...ListTile.divideTiles(
                  tiles: entries.mapIndexed((index, element) => ListTile(
                        title: Text("Team Number: ${element.teamNumber}"),
                      ))).toList(),
              ElevatedButton(
                  onPressed: () {
                    _isarModel.putAllScoutingData(entries);
                    context.pop();
                  },
                  child: const Text("Confirm")),
              ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancel")),

            ])));
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
      // Container(
      //   padding: const EdgeInsets.all(16.0),
      //   child: const Column(children: [
      //     Text("Select an option for importing data to GarageScouter",
      //         style: TextStyle(fontSize: 24)),
      //     Text(
      //         "Some options may not be available depending on the application's platform",
      //         style: TextStyle(fontSize: 16))
      //   ]),
      // ),
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
        title: const Text(
          "Import Data",
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(children: options),
    );
  }
}

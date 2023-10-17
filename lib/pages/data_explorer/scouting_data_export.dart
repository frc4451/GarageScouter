import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';
import 'package:robotz_garage_scouting/pages/data_explorer/scouting_data_utils.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

class ScoutingDataExportPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataExportPage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataExportPage> createState() => _ScoutingDataExportPageState();
}

class _ScoutingDataExportPageState extends State<ScoutingDataExportPage> {
  late final IsarModel _isarModel;
  late final StreamSubscription<List<ScoutingDataEntry>> _subscription;
  final List<int> _selectedIndices = [];
  List<ScoutingDataEntry> _entries = [];

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();

    _subscription = _isarModel
        .getScoutingData(widget.scoutingRouter.dataType)
        .listen((entries) {
      setState(() {
        _entries = entries;
      });
    });
  }

  @override
  void deactivate() {
    _subscription.cancel();
    super.deactivate();
  }

  Future<void> _handleDisplayQRCode(List<Map<String, dynamic>> jsons) async {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 16.0,
                insetPadding: const EdgeInsets.all(0.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double spaceBetween = 18.0;

                    final double maxQRCodeSize =
                        constraints.maxWidth > constraints.maxHeight
                            ? constraints.maxHeight * 0.75
                            : constraints.maxWidth * 0.9;

                    const double padY = 16;
                    const double padX = padY / 2;

                    final String qrCodeData = encodeJsonToB64({
                      "type": widget.scoutingRouter.displayName,
                      "data": jsons
                    }, urlSafe: true);

                    return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(padX, padY, padX, padY),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Scan this data with Import Manager",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: spaceBetween),
                            QrImageView(
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                              size: maxQRCodeSize,
                              data: qrCodeData,
                              errorStateBuilder: (context, error) => Column(
                                children: [
                                  const Text(
                                      "QR Code Failed to load because of the following"),
                                  Text(error.toString())
                                ],
                              ),
                            ),
                            const SizedBox(height: spaceBetween),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Done"),
                            ),
                          ],
                        ));
                  },
                )));
  }

  Future<void> _handleFileDialog(List<Map<String, dynamic>> jsons) async {
    final String filePath = await generateUniqueFilePath(
      extension: "csv",
      prefix:
          widget.scoutingRouter.displayName.toLowerCase().replaceAll(" ", "_"),
    );

    final File file = File(filePath);

    final List<String> rows = [];

    if (!validateProperties(jsons)) {
      errorMessageSnackbar(context, "Not all entries have the same schema.");
    }

    rows.add(convertListToCSVRow(jsons.first.keys.toList()));

    for (final json in jsons) {
      rows.add(convertListToCSVRow(json.values.toList()));
    }

    final File finalFile = await file.writeAsString(rows.join("\n"));

    saveFileToDevice(finalFile).then((File file) {
      saveFileSnackbar(context, file);
    }).catchError((error) {
      errorMessageSnackbar(context, error);
    });
  }

  void _cancel() {
    context.pop();
  }

  void _exportScoutingData() {
    List<Map<String, dynamic>> jsons = _selectedIndices
        .map((index) => _entries[index])
        .map((entry) => decodeJsonFromB64(entry.b64String ?? "{}"))
        .toList();

    const String qrKey = "qr";
    const String csvkey = "csv";

    showModalBottomSheet(
        isDismissible: true,
        context: context,
        builder: (context) => SizedBox(
              height: 100,
              child: Column(children: [
                ListTile(
                  title: const Text("QR Code"),
                  leading: const Icon(Icons.qr_code),
                  onTap: () {
                    context.pop(qrKey);
                  },
                ),
                ListTile(
                  title: const Text("CSV Export"),
                  leading: const Icon(Icons.file_download),
                  onTap: () {
                    context.pop(csvkey);
                  },
                ),
              ]),
            )).then((dynamic value) {
      String? response = value?.toString();
      if (response == qrKey) {
        _handleDisplayQRCode(jsons);
      } else if (response == csvkey) {
        _handleFileDialog(jsons);
      }
    });
  }

  void _selectIndex(int index) {
    setState(() {
      _selectedIndices.contains(index)
          ? _selectedIndices.remove(index)
          : _selectedIndices.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Export Data",
          textAlign: TextAlign.center,
        ),
      ),
      body: ExpansionTile(
          title: const Text("Completed"),
          subtitle: const Text(
              "Select each completed entry you would like to share, then press 'Export' at the bottom."),
          leading: const Icon(Icons.done),
          initiallyExpanded: true,
          children: ListTile.divideTiles(
              context: context,
              tiles: _entries.mapIndexed((index, entry) => ListTile(
                    title: Text(getScoutingListTileTitle(entry)),
                    subtitle: Text(getScoutingListTileSubtitle(entry)),
                    selected: _selectedIndices.contains(index),
                    leading: Icon(_selectedIndices.contains(index)
                        ? Icons.check_circle
                        : Icons.circle_outlined),
                    onTap: () {
                      _selectIndex(index);
                    },
                  ))).toList()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          OutlinedButton(onPressed: _cancel, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _exportScoutingData,
            child: const Text("Export"),
          ),
        ]),
      ),
    );
  }
}

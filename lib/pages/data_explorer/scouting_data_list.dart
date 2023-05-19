import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';

enum ScoutingType {
  pitScouting(value: "Pit Scouting"),
  matchScouting(value: "Match Scouting"),
  superScouting(value: "Super Scouting");

  final String value;

  const ScoutingType({required this.value});
}

class ScoutingDataListPage extends StatefulWidget {
  final ScoutingType scoutingType;

  const ScoutingDataListPage({super.key, required this.scoutingType});

  @override
  State<ScoutingDataListPage> createState() => _ScoutingDataListPageState();
}

class _ScoutingDataListPageState extends State<ScoutingDataListPage> {
  late Isar _isar;

  bool _loading = true;

  List<ScoutingDataEntry> _entries = [];

  bool _canExport = false;
  final List<int> _selectedIndices = [];

  Future<void> _listEntries() async {
    List<ScoutingDataEntry> queriedData = [];
    if (widget.scoutingType == ScoutingType.pitScouting) {
      queriedData = await _isar.pitScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .sortByTeamNumber()
          .findAll();
    }
    if (widget.scoutingType == ScoutingType.matchScouting) {
      queriedData = await _isar.matchScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .sortByMatchNumber()
          .findAll();
    }
    if (widget.scoutingType == ScoutingType.superScouting) {
      queriedData = await _isar.superScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .findAll();
    }

    setState(() {
      _entries = queriedData;
      _loading = false;
    });
  }

  String _getListTileTitle(ScoutingDataEntry entry) {
    if (entry is MatchScoutingEntry) {
      MatchScoutingEntry matchEntry = entry;
      return "Team Number: ${matchEntry.teamNumber}, Match Number: ${matchEntry.matchNumber}";
    }
    return "Team Number: ${entry.teamNumber}";
  }

  String _getListTileSubtitle(ScoutingDataEntry entry) {
    if (entry is MatchScoutingEntry) {
      MatchScoutingEntry matchEntry = entry;
      return "Alliance: ${matchEntry.alliance.color}";
    }

    return "Subtitle";
  }

  void _selectIndex(int index) {
    setState(() {
      _canExport && _selectedIndices.contains(index)
          ? _selectedIndices.remove(index)
          : _selectedIndices.add(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _isar = context.read<IsarModel>().isar;
    _listEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _canExport
              ? "Select what data you want to export"
              : "List of ${widget.scoutingType.value} Data",
          textAlign: TextAlign.center,
        ),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                if (value == "export") {
                  setState(() {
                    _canExport = true;
                  });
                } else if (value == "cancel") {
                  setState(() {
                    _selectedIndices.clear();
                    _canExport = false;
                  });
                } else if (value == "confirm") {
                  List<Map<String, dynamic>> jsons = [];
                  for (final entry in _entries) {
                    jsons.add(decodeJsonFromB64(entry.b64String ?? "{}"));
                  }

                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
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

                              return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      padX, padY, padX, padY),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Scan Data with Import Manager",
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
                                        data: encodeMultipleJsonToB64(jsons),
                                        errorStateBuilder: (context, error) =>
                                            Column(
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
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ));
                            },
                          )));
                }
              },
              itemBuilder: (context) => _canExport
                  ? [
                      const PopupMenuItem(
                          value: "cancel", child: Text("Cancel Export")),
                      const PopupMenuItem(
                          value: "confirm", child: Text("Confirm Export"))
                    ]
                  : [
                      const PopupMenuItem(
                          value: "export", child: Text("Export"))
                    ])
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (_entries.isEmpty && !_loading) {
            return ListTile(
              title: Text(
                "No items are in the database for ${widget.scoutingType.value}.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_getListTileTitle(_entries[index])),
                  subtitle: Text(_getListTileSubtitle(_entries[index])),
                  onTap: () {
                    if (_canExport) {
                      _selectIndex(index);
                    } else {
                      context.go(
                          "/data/match-scouting/${_entries[index].b64String}");
                    }
                  },
                  selected: _canExport && _selectedIndices.contains(index),
                );
              });
        },
      ),
    );
  }
}

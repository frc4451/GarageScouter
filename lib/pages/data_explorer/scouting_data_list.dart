import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_scouting.dart';
import 'package:robotz_garage_scouting/pages/pit_scouting_form.dart';
import 'package:robotz_garage_scouting/pages/super_scouting.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

class ScoutingDataListPage extends StatefulWidget {
  final ScoutingRouter scoutingRouter;

  const ScoutingDataListPage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataListPage> createState() => _ScoutingDataListPageState();
}

class _ScoutingDataListPageState extends State<ScoutingDataListPage> {
  late Isar _isar;

  bool _loading = true;

  List<ScoutingDataEntry> _entries = [];
  List<ScoutingDataEntry> _drafts = [];

  bool _canExport = false;
  final List<int> _selectedIndices = [];

  Future<void> _listEntries() async {
    List<ScoutingDataEntry> queriedDrafts = [];
    List<ScoutingDataEntry> queriedEntries = [];
    if (widget.scoutingRouter == ScoutingRouter.pitScouting) {
      queriedDrafts = await _isar.pitScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(true)
          .sortByTeamNumber()
          .findAll();
      queriedEntries = await _isar.pitScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(false)
          .sortByTeamNumber()
          .findAll();
    }
    if (widget.scoutingRouter == ScoutingRouter.matchScouting) {
      queriedDrafts = await _isar.matchScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(true)
          .sortByMatchNumber()
          .findAll();
      queriedEntries = await _isar.matchScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(false)
          .sortByMatchNumber()
          .findAll();
    }
    if (widget.scoutingRouter == ScoutingRouter.superScouting) {
      queriedDrafts = await _isar.superScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(true)
          .findAll();
      queriedEntries = await _isar.superScoutingEntrys
          .filter()
          .b64StringIsNotNull()
          .isDraftEqualTo(false)
          .findAll();
    }

    setState(() {
      _entries = queriedEntries;
      _drafts = queriedDrafts;
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

      if (_selectedIndices.isEmpty) {
        _canExport = false;
      }
    });
  }

  void _enableExport() {
    if (_entries.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have completed ${widget.scoutingRouter.displayName} data.");
      return;
    }

    setState(() {
      _selectedIndices.clear();
      _canExport = true;
    });
  }

  void _disableExport() {
    setState(() {
      _selectedIndices.clear();
      _canExport = false;
    });
  }

  void _enableImport() {
    informationSnackbar(context, "Will be implemented eventually.");
  }

  void _disableImport() {
    informationSnackbar(context, "Will be implemented eventually.");
  }

  void _exportScoutingData() {
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
                    padding: const EdgeInsets.fromLTRB(padX, padY, padX, padY),
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
                          data: encodeMultipleJsonToB64(jsons),
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
                          child: const Text("OK"),
                        ),
                      ],
                    ));
              },
            )));
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
          _canExport ? "Select Data" : widget.scoutingRouter.displayName,
          textAlign: TextAlign.center,
        ),
        // actions: [
        //   PopupMenuButton(
        //       onSelected: (value) {
        //         if (value == "export") {
        //           setState(() {
        //             _canExport = true;
        //           });
        //         } else if (value == "cancel") {
        //           setState(() {
        //             _selectedIndices.clear();
        //             _canExport = false;
        //           });
        //         } else if (value == "confirm") {}
        //       },
        //       itemBuilder: (context) => _canExport
        //           ? [
        //               const PopupMenuItem(
        //                   value: "cancel", child: Text("Cancel Export")),
        //               const PopupMenuItem(
        //                   value: "confirm", child: Text("Confirm Export"))
        //             ]
        //           : [
        //               const PopupMenuItem(
        //                   value: "export", child: Text("Export"))
        //             ])
        // ],
      ),
      bottomNavigationBar: Visibility(
          visible: _canExport,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor))),
            padding: const EdgeInsets.all(16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed: _disableExport, child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: _exportScoutingData,
                    child: const Text("Export"),
                  ),
                ]),
          )),
      body: Builder(
        builder: (context) {
          Color iconColor = Theme.of(context).colorScheme.primary;
          bool databaseNotEmpty = _drafts.isNotEmpty || _entries.isNotEmpty;

          // if (_loading) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
          // if (_drafts.isEmpty && _entries.isEmpty && !_loading) {
          //   return ListTile(
          //     title: Text(
          //       "No items are in the database for ${widget.scoutingRouter.displayName}.",
          //       textAlign: TextAlign.center,
          //     ),
          //   );
          // }

          return ListView(
            children: [
              if (!_canExport) ...[
                ListTile(
                  leading: const Icon(Icons.my_library_add_sharp),
                  iconColor: iconColor,
                  title:
                      Text("Collect ${widget.scoutingRouter.displayName} Data"),
                  onTap: () {
                    context
                        .goNamed('${widget.scoutingRouter.urlPath}-collection');
                  },
                ),
                ListTile(
                    leading: const Icon(Icons.import_export),
                    iconColor: iconColor,
                    title: Text(
                        "Import ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _enableImport()),
                ListTile(
                    leading: const Icon(Icons.import_export),
                    iconColor: iconColor,
                    title: Text(
                        "Export ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _enableExport()),
              ],
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (!databaseNotEmpty && !_loading)
                ListTile(
                  title: Text(
                    "No items are in the database for ${widget.scoutingRouter.displayName}.",
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!_canExport && databaseNotEmpty)
                ExpansionTile(
                  leading: const Icon(Icons.drafts),
                  title: const Text("Drafts"),
                  initiallyExpanded: _drafts.isNotEmpty,
                  children: [
                    for (final draft in _drafts)
                      ListTile(
                        title: Text(_getListTileTitle(draft)),
                        subtitle: Text(_getListTileSubtitle(draft)),
                        onTap: () {
                          context.goNamed(
                              '${widget.scoutingRouter.urlPath}-display',
                              params: {'hash': draft.b64String ?? ""});
                          // context.go(
                          //     "/data/${widget.scoutingRouter.urlPath}/${draft.b64String}");
                        },
                      )
                  ],
                ),
              if (databaseNotEmpty)
                ExpansionTile(
                  leading: const Icon(Icons.done),
                  title: const Text("Completed"),
                  initiallyExpanded: _entries.isNotEmpty,
                  children: [
                    for (int i = 0; i < _entries.length; ++i)
                      ListTile(
                        title: Text(_getListTileTitle(_entries[i])),
                        subtitle: Text(_getListTileSubtitle(_entries[i])),
                        selected: _canExport && _selectedIndices.contains(i),
                        onTap: () {
                          if (_canExport) {
                            _selectIndex(i);
                            return;
                          }
                          context.go(
                              "/data/${widget.scoutingRouter.urlPath}/${_entries[i].b64String}");
                        },
                      )
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

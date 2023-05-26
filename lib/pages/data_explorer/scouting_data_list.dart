import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

enum ScoutingDataActionState {
  initial,
  import,
  export,
  archive,
  delete;

  bool isInitial() => this == ScoutingDataActionState.initial;
  bool isNotInitial() => this != ScoutingDataActionState.initial;
  bool isImport() => this == ScoutingDataActionState.import;
  bool isExport() => this == ScoutingDataActionState.export;
  bool isArchive() => this == ScoutingDataActionState.archive;
  bool isDelete() => this == ScoutingDataActionState.delete;
}

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

  final List<int> _selectedIndices = [];

  ScoutingDataActionState _actionState = ScoutingDataActionState.initial;

  Future<void> _listEntries() async {
    setState(() {
      _loading = true;
    });

    List<ScoutingDataEntry> queriedDrafts = [];
    List<ScoutingDataEntry> queriedEntries = [];
    if (widget.scoutingRouter.isPitScouting()) {
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
    if (widget.scoutingRouter.isMatchScouting()) {
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
    if (widget.scoutingRouter.isSuperScouting()) {
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
      _actionState.isExport() && _selectedIndices.contains(index)
          ? _selectedIndices.remove(index)
          : _selectedIndices.add(index);

      if (_selectedIndices.isEmpty) {
        // _canExport = false;
        _actionState = ScoutingDataActionState.initial;
      }
    });
  }

  void _enableDelete() {
    if (_entries.isEmpty && _drafts.isEmpty) {
      errorMessageSnackbar(
          context, "You don't have ${widget.scoutingRouter.displayName} data.");
      return;
    }

    setState(() {
      _selectedIndices.clear();
      _actionState = ScoutingDataActionState.delete;
    });
  }

  void _enableImport() {
    informationSnackbar(context, "Will be implemented eventually.");
  }

  void _enableArchive() {
    informationSnackbar(context, "Will be implemented eventually.");
  }

  void _enableExport() {
    if (_entries.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have completed ${widget.scoutingRouter.displayName} data.");
      return;
    }

    setState(() {
      _selectedIndices.clear();
      _actionState = ScoutingDataActionState.export;
    });
  }

  void _resetState() {
    setState(() {
      _selectedIndices.clear();
      _actionState = ScoutingDataActionState.initial;
    });
  }

  String _getSubmitText() {
    return _actionState.isExport()
        ? "Export"
        : _actionState.isDelete()
            ? "Delete"
            : "Submit";
  }

  void _handleSubmit() {
    switch (_actionState) {
      case ScoutingDataActionState.import:
        return;
      case ScoutingDataActionState.export:
        _exportScoutingData();
        break;
      case ScoutingDataActionState.delete:
        _deleteDrafts();
        break;
      default:
        break;
    }
  }

  void _deleteDrafts() async {
    List<int> ids = _selectedIndices
        .map((index) => _drafts[index])
        .map((draft) => draft.id)
        .toList();

    // There may be a generic way to do this using Isar, but I haven't found it.
    if (widget.scoutingRouter.isPitScouting()) {
      _isar.writeTxn(() => _isar.pitScoutingEntrys.deleteAll(ids)).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    if (widget.scoutingRouter.isMatchScouting()) {
      _isar.writeTxn(() => _isar.matchScoutingEntrys.deleteAll(ids)).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    if (widget.scoutingRouter.isSuperScouting()) {
      _isar.writeTxn(() => _isar.superScoutingEntrys.deleteAll(ids)).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }

    _listEntries().then((_) {
      setState(() {
        _actionState = ScoutingDataActionState.initial;
        _listEntries();
      });
    });
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
          _actionState.isExport()
              ? "Export Data"
              : _actionState.isDelete()
                  ? "Delete Drafts"
                  : widget.scoutingRouter.displayName,
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
          visible: _actionState.isNotInitial(),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor))),
            padding: const EdgeInsets.all(16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed: _resetState, child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(_getSubmitText()),
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
              if (_actionState.isInitial()) ...[
                ListTile(
                  leading: const Icon(Icons.my_library_add_sharp),
                  iconColor: iconColor,
                  title:
                      Text("Collect ${widget.scoutingRouter.displayName} Data"),
                  onTap: () {
                    context
                        .pushNamed(
                            '${widget.scoutingRouter.urlPath}-collection')
                        .then((value) {
                      _listEntries();
                    });
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
                // ListTile(
                //     leading: const Icon(Icons.archive),
                //     iconColor: iconColor,
                //     title: Text(
                //         "Archive ${widget.scoutingRouter.displayName} Data"),
                //     onTap: () => _enableArchive()),
                ListTile(
                    leading: const Icon(Icons.delete),
                    iconColor: iconColor,
                    title: Text(
                        "Delete ${widget.scoutingRouter.displayName} Drafts"),
                    onTap: () => _enableDelete())
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
              if (!_actionState.isExport() && databaseNotEmpty && !_loading)
                ExpansionTile(
                  leading: const Icon(Icons.drafts),
                  title: const Text("Drafts"),
                  initiallyExpanded: _drafts.isNotEmpty,
                  children: [
                    for (int i = 0; i < _drafts.length; ++i)
                      ListTile(
                        title: Text(_getListTileTitle(_drafts[i])),
                        subtitle: Text(_getListTileSubtitle(_drafts[i])),
                        selected: _actionState.isDelete() &&
                            _selectedIndices.contains(i),
                        onTap: () {
                          if (_actionState.isDelete()) {
                            _selectIndex(i);
                            return;
                          }
                          context.goNamed(
                              '${widget.scoutingRouter.urlPath}-display',
                              params: {'hash': _drafts[i].b64String ?? ""});
                        },
                      )
                  ],
                ),
              if (!_actionState.isDelete() && databaseNotEmpty && !_loading)
                ExpansionTile(
                  leading: const Icon(Icons.done),
                  title: const Text("Completed"),
                  initiallyExpanded: _entries.isNotEmpty,
                  children: [
                    for (int i = 0; i < _entries.length; ++i)
                      ListTile(
                        title: Text(_getListTileTitle(_entries[i])),
                        subtitle: Text(_getListTileSubtitle(_entries[i])),
                        selected: _actionState.isExport() &&
                            _selectedIndices.contains(i),
                        onTap: () {
                          if (_actionState.isExport()) {
                            _selectIndex(i);
                            return;
                          }
                          context.goNamed(
                              '${widget.scoutingRouter.urlPath}-display',
                              params: {'hash': _entries[i].b64String ?? ""});
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

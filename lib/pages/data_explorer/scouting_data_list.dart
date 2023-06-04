import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/extensions/datetime_extensions.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';
import 'package:robotz_garage_scouting/utils/extensions/string_extensions.dart';

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
  late IsarModel _isarModel;

  List<ScoutingDataEntry> _entries = [];
  List<ScoutingDataEntry> _drafts = [];

  // We opt for StreamSubscriptions over using StreamBuilder to allow
  // synchronous lookups over drafts and entries and reduce complexity.
  late StreamSubscription<List<ScoutingDataEntry>> _entriesStreamSubscription;
  late StreamSubscription<List<ScoutingDataEntry>> _draftsStreamSubscription;

  final List<int> _selectedIndices = [];

  ScoutingDataActionState _actionState = ScoutingDataActionState.initial;

  String _getListTileTitle(ScoutingDataEntry entry) {
    if (entry is MatchScoutingEntry) {
      MatchScoutingEntry matchEntry = entry;
      return "Team Number: ${matchEntry.teamNumber}, Match Number: ${matchEntry.matchNumber}";
    }
    return "Team Number: ${entry.teamNumber}";
  }

  String _getListTileSubtitle(ScoutingDataEntry entry) {
    List<String> rows = [];

    if (entry is MatchScoutingEntry) {
      MatchScoutingEntry matchEntry = entry;
      rows.add("Alliance: ${matchEntry.alliance.color.capitalizeFirst()}");
    }

    rows.add("Last updated at ${entry.timestamp.standardizedFormat()}");

    return rows.join("\n");
  }

  void _selectIndex(int index) {
    setState(() {
      _actionState.isExport() && _selectedIndices.contains(index)
          ? _selectedIndices.remove(index)
          : _selectedIndices.add(index);

      if (_selectedIndices.isEmpty) {
        _actionState = ScoutingDataActionState.initial;
      }
    });
  }

  void _enableDelete() {
    if (_drafts.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have ${widget.scoutingRouter.displayName} drafts.");
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
      _isarModel.deletePitScoutingByIDs(ids).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    if (widget.scoutingRouter.isMatchScouting()) {
      _isarModel.deleteMatchScoutingByIDs(ids).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
    if (widget.scoutingRouter.isSuperScouting()) {
      _isarModel.deleteSuperScoutingByIDs(ids).then(
        (_) {
          successMessageSnackbar(context, "Successfully deleted draft(s)");
        },
      ).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }

    setState(() {
      _selectedIndices.clear();
      _actionState = ScoutingDataActionState.initial;
    });
  }

  void _exportScoutingData() {
    List<Map<String, dynamic>> jsons = _entries
        .map((entry) => decodeJsonFromB64(entry.b64String ?? "{}"))
        .toList();

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
                          data: encodeJsonToB64({
                            "type": widget.scoutingRouter.displayName,
                            "data": jsons
                          }),
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

    _isarModel = context.read<IsarModel>();

    Stream<List<ScoutingDataEntry>> entriesStream =
        _isarModel.getScoutingData(widget.scoutingRouter.dataType);
    Stream<List<ScoutingDataEntry>> draftsStream =
        _isarModel.getScoutingDrafts(widget.scoutingRouter.dataType);

    _entriesStreamSubscription = entriesStream.listen((entries) {
      setState(() {
        _entries = entries;
      });
    });

    _draftsStreamSubscription = draftsStream.listen((drafts) {
      setState(() {
        _drafts = drafts;
      });
    });
  }

  @override
  void deactivate() {
    _entriesStreamSubscription.cancel();
    _draftsStreamSubscription.cancel();

    super.deactivate();
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

          return ListView(
            children: [
              Visibility(
                visible: _actionState.isInitial(),
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.my_library_add_sharp),
                    iconColor: iconColor,
                    title: Text(
                        "Collect ${widget.scoutingRouter.displayName} Data"),
                    onTap: () {
                      context.pushNamed(
                          '${widget.scoutingRouter.urlPath}-collection');
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
                ]),
              ),
              Visibility(
                visible: !databaseNotEmpty,
                child: ListTile(
                  title: Text(
                    "No items are in the database for ${widget.scoutingRouter.displayName}.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Visibility(
                  visible: !_actionState.isExport() && databaseNotEmpty,
                  child: ExpansionTile(
                      leading: const Icon(Icons.drafts),
                      title: const Text("Drafts"),
                      initiallyExpanded: true,
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: _drafts.mapIndexed(
                            (index, draft) => ListTile(
                              title: Text(_getListTileTitle(draft)),
                              subtitle: Text(_getListTileSubtitle(draft)),
                              selected: _actionState.isDelete() &&
                                  _selectedIndices.contains(index),
                              onTap: () {
                                if (_actionState.isDelete()) {
                                  _selectIndex(index);
                                  return;
                                }
                                context.pushNamed(
                                    "${widget.scoutingRouter.urlPath}-collection",
                                    queryParams: {"uuid": draft.uuid});
                              },
                            ),
                          )).toList())),
              Visibility(
                visible: !_actionState.isDelete() && databaseNotEmpty,
                child: ExpansionTile(
                    title: const Text("Completed"),
                    leading: const Icon(Icons.done),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: _entries.mapIndexed((index, entry) => ListTile(
                              title: Text(_getListTileTitle(entry)),
                              subtitle: Text(_getListTileSubtitle(entry)),
                              selected: _actionState.isExport() &&
                                  _selectedIndices.contains(index),
                              onTap: () {
                                if (_actionState.isExport()) {
                                  _selectIndex(index);
                                  return;
                                }
                                context.goNamed(
                                    '${widget.scoutingRouter.urlPath}-display',
                                    params: {'hash': entry.b64String ?? ""});
                              },
                            ))).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}

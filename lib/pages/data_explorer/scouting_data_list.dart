import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/pages/data_explorer/scouting_data_utils.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

class ScoutingDataListPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

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

  void _goToImportPage() {
    context.goNamed(widget.scoutingRouter.getImportRouteName());
  }

  void _goToExportPage() {
    if (_entries.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have completed ${widget.scoutingRouter.displayName} data.");
      return;
    }
    context.goNamed(widget.scoutingRouter.getExportRouteName());
  }

  void _goToDeletePage() {
    if (_drafts.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have ${widget.scoutingRouter.displayName} drafts.");
      return;
    }

    context.goNamed(widget.scoutingRouter.getDeleteRouteName());
  }

  void _goToCollectionPage() {
    context.pushNamed('${widget.scoutingRouter.urlPath}-collection');
  }

  void _goToDraftCompletionPage(ScoutingDataEntry draft) {
    context.pushNamed("${widget.scoutingRouter.urlPath}-collection",
        queryParams: {"uuid": draft.uuid});
  }

  void _goToDisplayPage(ScoutingDataEntry entry) {
    context.goNamed('${widget.scoutingRouter.urlPath}-display',
        params: {'hash': entry.b64String ?? ""});
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
          widget.scoutingRouter.displayName,
          textAlign: TextAlign.center,
        ),
      ),
      body: Builder(
        builder: (context) {
          Color iconColor = Theme.of(context).colorScheme.primary;
          bool databaseNotEmpty = _drafts.isNotEmpty || _entries.isNotEmpty;

          return ListView(
            children: [
              Column(children: [
                ListTile(
                    leading: const Icon(Icons.my_library_add_sharp),
                    iconColor: iconColor,
                    title: Text(
                        "Collect ${widget.scoutingRouter.displayName} Data"),
                    subtitle:
                        const Text("Open form input and collect new data."),
                    onTap: () => _goToCollectionPage()),
                ListTile(
                    leading: const Icon(Icons.import_contacts),
                    iconColor: iconColor,
                    title: Text(
                        "Import ${widget.scoutingRouter.displayName} Data"),
                    subtitle: const Text("Import data from other users."),
                    onTap: () => _goToImportPage()),
                ListTile(
                    leading: const Icon(Icons.file_download),
                    iconColor: iconColor,
                    title: Text(
                        "Export ${widget.scoutingRouter.displayName} Data"),
                    subtitle: const Text(
                        "Export data from device for external applcations, or sharing with other users. CSV outputs can be imported to Microsoft Excel or Google Sheets."),
                    onTap: () => _goToExportPage()),
                ListTile(
                    leading: const Icon(Icons.delete),
                    iconColor: iconColor,
                    title: Text(
                        "Delete ${widget.scoutingRouter.displayName} Drafts"),
                    subtitle: const Text(
                        "Delete drafts that are no longer needed. Completed entries cannot be deleted at this time."),
                    onTap: () => _goToDeletePage())
              ]),
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
                  visible: databaseNotEmpty,
                  child: ExpansionTile(
                      leading: const Icon(Icons.drafts),
                      title: const Text("Drafts"),
                      subtitle: const Text(
                          "Incomplete entries. Click on a draft to fill-out the form and move to the 'Complete' tab."),
                      initiallyExpanded: true,
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: _drafts.mapIndexed(
                            (index, draft) => ListTile(
                              title: Text(getScoutingListTileTitle(draft)),
                              subtitle:
                                  Text(getScoutingListTileSubtitle(draft)),
                              onTap: () => _goToDraftCompletionPage(draft),
                            ),
                          )).toList())),
              Visibility(
                visible: databaseNotEmpty,
                child: ExpansionTile(
                    title: const Text("Completed"),
                    subtitle: const Text(
                        "Finished entries. Click on an entry to see the results from the entry."),
                    leading: const Icon(Icons.done),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: _entries.mapIndexed((index, entry) => ListTile(
                              title: Text(getScoutingListTileTitle(entry)),
                              subtitle:
                                  Text(getScoutingListTileSubtitle(entry)),
                              onTap: () => _goToDisplayPage(entry),
                            ))).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}

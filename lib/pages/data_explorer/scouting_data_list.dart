import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_utils.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class ScoutingDataListPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataListPage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataListPage> createState() => _ScoutingDataListPageState();
}

class _ScoutingDataListPageState extends State<ScoutingDataListPage> {
  late IsarModel _isarModel;

  Event? _selectedEvent;

  List<ScoutingDataEntry> _entries = [];
  List<ScoutingDataEntry> _drafts = [];

  // We opt for StreamSubscriptions over using StreamBuilder to allow
  // synchronous lookups over drafts and entries and reduce complexity.
  late StreamSubscription<List<ScoutingDataEntry>> _entriesStreamSubscription;
  late StreamSubscription<List<ScoutingDataEntry>> _draftsStreamSubscription;
  late StreamSubscription<Event?> _eventSubscription;

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
        queryParameters: {"uuid": draft.uuid});
  }

  void _goToDisplayPage(ScoutingDataEntry entry) {
    context.goNamed('${widget.scoutingRouter.urlPath}-display',
        queryParameters: {'hash': entry.b64String ?? ""});
  }

  void _goToEventSelectionPage() {
    context.goNamed(widget.scoutingRouter.getEventsRouteName());
  }

  void _goToDataTablePage() {
    if (_entries.isEmpty) {
      errorMessageSnackbar(context,
          "You don't have completed ${widget.scoutingRouter.displayName} data.");
      return;
    }
    context.goNamed(widget.scoutingRouter.getDataTableRouteName());
  }

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();

    Stream<List<ScoutingDataEntry>> entriesStream =
        _isarModel.getScoutingData(widget.scoutingRouter.dataType);
    Stream<List<ScoutingDataEntry>> draftsStream =
        _isarModel.getScoutingDrafts(widget.scoutingRouter.dataType);

    Stream<Event?> eventStream = _isarModel.getCurrentEventStream();

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

    _eventSubscription = eventStream.listen((event) {
      setState(() {
        if (event != null) {
          _selectedEvent = event;
        }
      });
    });

    // _isarModel.getCurrentEvent().then((Event event) {
    //   setState(() {
    //     _selectedEvent = event;
    //   });
    // });
  }

  @override
  void deactivate() {
    _entriesStreamSubscription.cancel();
    _draftsStreamSubscription.cancel();
    _eventSubscription.cancel();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scoutingRouter.displayName),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          Color iconColor = Theme.of(context).colorScheme.primary;
          bool databaseNotEmpty = _drafts.isNotEmpty || _entries.isNotEmpty;

          return ListView(
            children: [
              Column(
                  children: ListTile.divideTiles(context: context, tiles: [
                ListTile(
                  leading: const Icon(Icons.event),
                  iconColor: iconColor,
                  title: Text("Event: ${_selectedEvent?.name}"),
                  onTap: () => _goToEventSelectionPage(),
                ),
                ListTile(
                    leading: const Icon(Icons.my_library_add_sharp),
                    iconColor: iconColor,
                    title: Text(
                        "Collect ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _goToCollectionPage()),
                ListTile(
                    leading: const Icon(Icons.import_contacts),
                    iconColor: iconColor,
                    title: Text(
                        "Import ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _goToImportPage()),
                ListTile(
                    leading: const Icon(Icons.file_download),
                    iconColor: iconColor,
                    title: Text(
                        "Export ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _goToExportPage()),
                ListTile(
                    leading: const Icon(Icons.delete),
                    iconColor: iconColor,
                    title: Text(
                        "Delete ${widget.scoutingRouter.displayName} Drafts"),
                    onTap: () => _goToDeletePage()),
                ListTile(
                    leading: const Icon(Icons.view_list),
                    iconColor: iconColor,
                    title: Text(
                        "View all ${widget.scoutingRouter.displayName} Data"),
                    onTap: () => _goToDataTablePage()),
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
                            "Incomplete entries. Click on a draft to complete the form."),
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
                          "Finished entries. Click on an entry to see the data."),
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
              ]).toList()),
            ],
          );
        },
      ),
    );
  }
}

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

class ScoutingDataDeletePage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataDeletePage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataDeletePage> createState() => _ScoutingDataDeletePageState();
}

class _ScoutingDataDeletePageState extends State<ScoutingDataDeletePage> {
  late final IsarModel _isarModel;
  late final StreamSubscription<List<ScoutingDataEntry>> _subscription;
  final List<int> _selectedIndices = [];
  List<ScoutingDataEntry> _drafts = [];

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();

    _subscription = _isarModel
        .getScoutingDrafts(widget.scoutingRouter.dataType)
        .listen((drafts) {
      setState(() {
        _drafts = drafts;
      });
    });
  }

  @override
  void deactivate() {
    _subscription.cancel();
    super.deactivate();
  }

  Future<void> _deleteDrafts() async {
    bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 16.0,
        insetPadding: const EdgeInsets.all(0.0),
        title: const Text("Are you sure you want to delete these drafts?"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  context.pop(false);
                },
              ),
              ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () {
                  context.pop(true);
                },
              ),
            ],
          )
        ],
      ),
    );

    if (didConfirm == null || !didConfirm) {
      return;
    }

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
    });
  }

  void _cancel() {
    context.pop();
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
          "Delete Drafts",
          textAlign: TextAlign.center,
        ),
      ),
      body: ExpansionTile(
          title: const Text("Drafts"),
          subtitle: const Text(
              "Select each draft you would like to delete, then press 'Delete' at the bottom."),
          leading: const Icon(Icons.drafts),
          initiallyExpanded: true,
          children: ListTile.divideTiles(
              context: context,
              tiles: _drafts.mapIndexed((index, entry) => ListTile(
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
            onPressed: _deleteDrafts,
            child: const Text("Delete"),
          ),
        ]),
      ),
    );
  }
}

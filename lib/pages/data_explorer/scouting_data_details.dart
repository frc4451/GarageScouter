import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ScoutingDataDetailsPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  final String? uuid;

  const ScoutingDataDetailsPage(
      {super.key, required this.scoutingRouter, this.uuid});

  @override
  State<ScoutingDataDetailsPage> createState() =>
      _ScoutingDataDetailsPageState();
}

class _ScoutingDataDetailsPageState extends State<ScoutingDataDetailsPage> {
  late IsarModel _isar;
  late ScoutingDataEntry _entry;

  String? _error;

  @override
  void initState() {
    super.initState();

    _isar = context.read<IsarModel>();
    _entry = ScoutingDataEntry();

    Future<ScoutingDataEntry>? callback;

    switch (widget.scoutingRouter) {
      case GarageRouter.pitScouting:
        callback = _isar.getPitDataByUUID(widget.uuid ?? "");
        break;
      case GarageRouter.matchScouting:
        callback = _isar.getMatchDataByUUID(widget.uuid ?? "");
        break;
      case GarageRouter.superScouting:
        callback = _isar.getSuperDataByUUID(widget.uuid ?? "");
        break;
      default:
        _error = "The router configuration provided is invalid.";
        break;
    }

    callback?.then((entry) {
      setState(() {
        _entry = entry;
      });
    });
  }

  Future<void> _deleteEntry() async {
    bool? willDelete = await showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              content:
                  const Text("Are you sure you want to delete this entry?"),
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
            )));

    if (willDelete ?? false) {
      Future<bool>? callback;

      switch (widget.scoutingRouter) {
        case GarageRouter.pitScouting:
          callback = _isar.deletePitScoutingByID(_entry.id);
          break;
        case GarageRouter.matchScouting:
          callback = _isar.deleteMatchScoutingByID(_entry.id);
          break;
        case GarageRouter.superScouting:
          callback = _isar.deleteSuperScoutingByID(_entry.id);
          break;
        default:
          _error = "Invalid router configuration provided";
          break;
      }

      callback?.then((bool didDelete) {
        if (didDelete) {
          successMessageSnackbar(context,
              "Successfully removed ${widget.scoutingRouter.displayName} Entry.");
        }
        context.pop();
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = decodeJsonFromB64(_entry.b64String);

    return Scaffold(
        appBar: AppBar(
            title: const Text("Scouting Data"),
            centerTitle: true,
            actions: [
              PopupMenuButton(
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: _deleteEntry,
                          child: const Text("Delete"),
                        ),
                      ])
            ]),
        body: (_error ?? "").isNotEmpty
            ? Center(child: Text(_error!))
            : DataTable2(
                columns: const [
                  DataColumn2(label: Text("Key")),
                  DataColumn2(label: Text("Value")),
                ],
                rows: data.keys
                    .map((String key) => DataRow2(cells: [
                          DataCell(Text(key)),
                          DataCell(Text(data[key].toString()))
                        ]))
                    .toList(),
              ));
  }
}

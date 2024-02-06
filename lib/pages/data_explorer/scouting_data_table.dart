import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:garagescouter/constants/platform_check.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:provider/provider.dart';

class ScoutingDataTablePage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataTablePage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataTablePage> createState() => _ScoutingDataTablePageState();
}

class _ScoutingDataTablePageState extends State<ScoutingDataTablePage> {
  late IsarModel _isarModel;
  late StreamSubscription<List<ScoutingDataEntry>> _entriesStreamSubscription;
  List<ScoutingDataEntry> _entries = [];

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();

    Stream<List<ScoutingDataEntry>> entriesStream =
        _isarModel.getScoutingData(widget.scoutingRouter.dataType);

    _entriesStreamSubscription = entriesStream.listen((entries) {
      setState(() {
        _entries = entries;
      });
    });
  }

  @override
  void deactivate() {
    _entriesStreamSubscription.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    List<String> columns = [];

    // Assuming we've read our entries, we can find common columns between
    // all selected entries.
    if (_entries.isNotEmpty) {
      columns = _entries
          .map((ScoutingDataEntry e) =>
              decodeJsonFromB64(e.b64String).keys.toList())
          .reduce((List<String> commonColumns, List<String> row) =>
              commonColumns.where((column) => row.contains(column)).toList())
          .toList();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.scoutingRouter.displayName} Data"),
          centerTitle: true,
        ),
        body: columns.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: columns.length * 120,
                fixedLeftColumns: isDesktopPlatform() ? 2 : 1,
                columns: columns
                    .map((column) => DataColumn2(label: Text(column)))
                    .toList(),
                rows: _entries.map((ScoutingDataEntry entry) {
                  Map<String, dynamic> data =
                      decodeJsonFromB64(entry.b64String);

                  return DataRow2(
                      cells: columns
                          .map((column) =>
                              DataCell(Text(data[column].toString())))
                          .toList());
                }).toList()));
  }
}

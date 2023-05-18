import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';

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

  Future<void> _listEntries() async {
    List<ScoutingDataEntry> queriedData = [];
    if (widget.scoutingType == ScoutingType.pitScouting) {
      queriedData = await _isar.pitScoutingEntrys
          .filter()
          .teamNumberIsNotNull()
          .findAll();
    }
    if (widget.scoutingType == ScoutingType.matchScouting) {
      queriedData = await _isar.matchScoutingEntrys
          .filter()
          .teamNumberIsNotNull()
          .findAll();
    }
    if (widget.scoutingType == ScoutingType.superScouting) {
      queriedData = await _isar.superScoutingEntrys
          .filter()
          .teamNumberIsNotNull()
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
          "List of ${widget.scoutingType.value} Data",
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(children: [
        if (_loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (_entries.isEmpty && !_loading)
          ListTile(
            title: Text(
              "No items are in the database for ${widget.scoutingType.value}.",
              textAlign: TextAlign.center,
            ),
          ),
        for (final entry in _entries)
          ListTile(
            title: Text(_getListTileTitle(entry)),
            subtitle: Text(_getListTileSubtitle(entry)),
          )
      ]),
    );
  }
}

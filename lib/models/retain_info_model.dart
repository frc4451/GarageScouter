import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const String retainInfoSettingsFileName = "retain.settings.json";

enum TempFilePath { matchScouting, pitScouting, superScouting, general }

extension TempFileNamesExtension on TempFilePath {
  String get value {
    switch (this) {
      case TempFilePath.matchScouting:
        return "temp.match_scouting.json";

      case TempFilePath.pitScouting:
        return "temp.pit_scouting.json";

      case TempFilePath.superScouting:
        return "temp.super_scouting.json";

      case TempFilePath.general:
        return "retain.settings.json";
    }
  }
}

// final String retainInfoSettingsFileName = TempFilePath.matchScouting.value;

class RetainInfoModel extends ChangeNotifier {
  bool _retainInfo = false;

  bool retainInfo() => _retainInfo;

  Map<String, dynamic> _pitScouting;
  Map<String, dynamic> _matchScouting;
  Map<String, dynamic> _superScouting;

  // For all accessors we check if the user cares to retain information on
  // incomplete submissions. If the user does _not_ plan to retain the
  // information we just return an empty Map with String indices
  Map<String, dynamic> pitScouting() =>
      _retainInfo ? _pitScouting : <String, dynamic>{};
  Map<String, dynamic> matchScouting() =>
      _retainInfo ? _matchScouting : <String, dynamic>{};
  Map<String, dynamic> superScouting() =>
      _retainInfo ? _superScouting : <String, dynamic>{};

  Future<void> setPitScouting(Map<String, dynamic> pitScouting) async {
    _pitScouting = pitScouting;
    await _writeData(TempFilePath.pitScouting, _pitScouting);
  }

  Future<void> setMatchScouting(Map<String, dynamic> matchScouting) async {
    _matchScouting = matchScouting;
    await _writeData(TempFilePath.matchScouting, _matchScouting);
  }

  void setSuperScouting(Map<String, dynamic> superScouting) {
    _superScouting = superScouting;
    _writeData(TempFilePath.superScouting, _superScouting);
  }

  // These are helper methods to more verbosely say we're resetting the data.
  void resetPitScouting() => setPitScouting({});
  void resetMatchScouting() => setMatchScouting({});
  void resetSuperScouting() => setSuperScouting({});

  void setRetainInfo(bool value) {
    _retainInfo = value;
    _writeData(TempFilePath.general, settingsToJson());
    notifyListeners();
  }

  RetainInfoModel(
      {bool? retainInfo,
      Map<String, dynamic>? pitScouting,
      Map<String, dynamic>? matchScouting,
      Map<String, dynamic>? superScouting})
      : _pitScouting = pitScouting ?? {},
        _matchScouting = matchScouting ?? {},
        _superScouting = superScouting ?? {},
        _retainInfo = retainInfo ?? false;

  /// fromSettingsJson expects to have the initial data from the retain.settings.json
  /// but to check for the existence of other data.
  factory RetainInfoModel.fromJsons(Map<String, Map<String, dynamic>> json) {
    // Handle Settings State before raw form data
    Map<String, dynamic> assumedSettings = json['settings'] ?? {};
    bool assumedRetainInfo = assumedSettings['retainInfo'] ?? false;

    Map<String, dynamic> assumedPitScouting = json['pit_scouting'] ?? {};
    Map<String, dynamic> assumedMatchScouting = json['match_scouting'] ?? {};
    Map<String, dynamic> assumedSuperScouting = json['super_scouting'] ?? {};

    return RetainInfoModel(
        retainInfo: assumedRetainInfo,
        pitScouting: assumedPitScouting,
        matchScouting: assumedMatchScouting,
        superScouting: assumedSuperScouting);
  }

  Map<String, dynamic> settingsToJson() {
    return {'retainInfo': _retainInfo};
  }

  bool doesRetainInfo() => _retainInfo;

  /// Writes data to disk with specification for the TempFilePath provided.
  Future<void> _writeData(TempFilePath file, Map<String, dynamic> data) async {
    final String path = (await getApplicationSupportDirectory()).path;
    final String jsonPath = p.join(path, file.value);
    final File jsonFile = File(jsonPath);

    jsonFile.writeAsStringSync(jsonEncode(data));
  }
}

/// Handles reading data from a specified TempFilePath file. This is agnostic
/// to what data is actually in the file and only cares that the file exists
/// or returns an empty Map object.
Future<Map<String, dynamic>> getDataFromJsonFile(TempFilePath filePath) async {
  final String path = (await getApplicationSupportDirectory()).path;
  final String jsonPath = p.join(path, filePath.value);
  final File jsonFile = File(jsonPath);

  // null check to make sure we're not opening a file that doesn't exist.
  if (!jsonFile.existsSync()) {
    return {};
  }

  return jsonDecode(await jsonFile.readAsString());
}

/// Creates an initial RetainInfoModel we can use for Providers
/// It will pull data from the settings and temp data files in order
/// to populate the values of the Model.
Future<RetainInfoModel> getInitialRetainModel() async {
  return RetainInfoModel.fromJsons({
    'settings': await getDataFromJsonFile(TempFilePath.general),
    'pit_scouting': await getDataFromJsonFile(TempFilePath.pitScouting),
    'match_scouting': await getDataFromJsonFile(TempFilePath.matchScouting),
    'super_scouting': await getDataFromJsonFile(TempFilePath.superScouting)
  });
}

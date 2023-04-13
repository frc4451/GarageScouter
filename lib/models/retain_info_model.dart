import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kRetainInfoConfigKey = "retainInfoConfig";
const String kRetainInfoDataKey = "retainInfoData";
const String kPitScoutingKey = "pit_scouting";
const String kMatchScoutingKey = "match_scouting";
const String kSuperScoutingKey = "super_scouting";

class RetainInfoModel extends ChangeNotifier {
  SharedPreferences prefs;

  bool _retainInfo = false;

  bool retainInfo() => _retainInfo;

  Map<String, dynamic> _pitScouting = {};
  Map<String, dynamic> _matchScouting = {};
  Map<String, dynamic> _superScouting = {};

  RetainInfoModel(this.prefs);

  Future<void> initialize() async {
    _retainInfo = prefs.getBool(kRetainInfoConfigKey) ?? false;

    Map<String, dynamic> parsedJsonData =
        jsonDecode(prefs.getString(kRetainInfoDataKey) ?? "{}");

    _pitScouting = parsedJsonData[kPitScoutingKey] ?? {};
    _matchScouting = parsedJsonData[kMatchScoutingKey] ?? {};
    _superScouting = parsedJsonData[kSuperScoutingKey] ?? {};
  }

  // For all accessors we check if the user cares to retain information on
  // incomplete submissions. If the user does _not_ plan to retain the
  // information we just return an empty Map with String indices
  Map<String, dynamic> pitScouting() =>
      _retainInfo ? _pitScouting : <String, dynamic>{};
  Map<String, dynamic> matchScouting() =>
      _retainInfo ? _matchScouting : <String, dynamic>{};
  Map<String, dynamic> superScouting() =>
      _retainInfo ? _superScouting : <String, dynamic>{};

  void setPitScouting(Map<String, dynamic> pitScouting) {
    _pitScouting = pitScouting;
    _writeData();
    notifyListeners();
  }

  void setMatchScouting(Map<String, dynamic> matchScouting) {
    _matchScouting = matchScouting;
    _writeData();
    notifyListeners();
  }

  void setSuperScouting(Map<String, dynamic> superScouting) {
    _superScouting = superScouting;
    _writeData();
    notifyListeners();
  }

  // These are helper methods to more verbosely say we're resetting the data.
  void resetPitScouting() => setPitScouting({});
  void resetMatchScouting() => setMatchScouting({});
  void resetSuperScouting() => setSuperScouting({});

  void setRetainInfo(bool value) {
    _retainInfo = value;
    prefs.setBool(kRetainInfoConfigKey, _retainInfo);
    notifyListeners();
  }

  bool doesRetainInfo() => _retainInfo;

  /// Writes data to disk with specification for the TempFilePath provided.
  void _writeData() {
    prefs.setBool(kRetainInfoConfigKey, _retainInfo);
    prefs.setString(
        kRetainInfoDataKey,
        jsonEncode({
          kPitScoutingKey: _pitScouting,
          kMatchScoutingKey: _matchScouting,
          kSuperScoutingKey: _superScouting
        }));
  }
}

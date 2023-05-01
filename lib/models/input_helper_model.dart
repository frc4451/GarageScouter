import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kIterativeMatchScoutingKey = "isIterativeMatchScouting";

class InputHelperModel extends ChangeNotifier {
  final SharedPreferences prefs;

  bool _isIterativeMatchInput = false;

  InputHelperModel(this.prefs);

  bool isIterativeMatchInput() => _isIterativeMatchInput;

  void setIterativeMatchInput(bool value) {
    _isIterativeMatchInput = value;
    _writeData();
    notifyListeners();
  }

  void _writeData() {
    prefs.setBool(kIterativeMatchScoutingKey, _isIterativeMatchInput);
  }

  void initialize() {
    _isIterativeMatchInput = prefs.getBool(kIterativeMatchScoutingKey) ?? false;
  }
}

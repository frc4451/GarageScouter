import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kIsDisabledSwiping = "isDisabledSwiping";

/// Handles Scroll Configurations on Forms
class ScrollModel extends ChangeNotifier {
  final SharedPreferences prefs;

  bool _disableSwiping = false;

  bool get disableSwiping => _disableSwiping;

  void setDisableSwiping(bool value) {
    _disableSwiping = value;
    _writeData();
    notifyListeners();
  }

  ScrollModel(this.prefs);

  bool canSwipe() => _disableSwiping;

  void _writeData() {
    prefs.setBool(kIsDisabledSwiping, _disableSwiping);
  }

  void initialize() {
    _disableSwiping = prefs.getBool(kIsDisabledSwiping) ?? false;
  }
}

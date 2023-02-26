import 'package:flutter/material.dart';

class ScrollModel extends ChangeNotifier {
  bool _disableSwiping = false;

  void setDisableSwiping(bool value) {
    _disableSwiping = value;
    notifyListeners();
  }

  bool canSwipe() => _disableSwiping;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const String scrollSettingsFileName = "scroll.settings.json";

class ScrollModel extends ChangeNotifier {
  bool _disableSwiping = false;

  void setDisableSwiping(bool value) {
    _disableSwiping = value;
    _writeData();
    notifyListeners();
  }

  ScrollModel({bool? disableSwiping})
      : _disableSwiping = disableSwiping ?? false;

  factory ScrollModel.fromJson(Map<String, dynamic> json) {
    bool assumedSwiping = json['disableSwiping'];
    return ScrollModel(disableSwiping: assumedSwiping);
  }

  Map<String, dynamic> toJson() {
    return {'disableSwiping': _disableSwiping};
  }

  bool canSwipe() => _disableSwiping;

  Future<void> _writeData() async {
    final String path = (await getApplicationSupportDirectory()).path;
    final String jsonPath = p.join(path, scrollSettingsFileName);
    final File jsonFile = File(jsonPath);

    jsonFile.writeAsStringSync(jsonEncode(toJson()));
  }
}

Future<ScrollModel> getInitialScrollModel() async {
  final String settingsDirectory =
      (await getApplicationSupportDirectory()).path;
  final String jsonPath = p.join(settingsDirectory, scrollSettingsFileName);
  final File jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    final ScrollModel model = ScrollModel();
    await model._writeData();
    return model;
  }

  final String jsonString = jsonFile.readAsStringSync();
  final dynamic decodedJson = jsonDecode(jsonString);

  return ScrollModel.fromJson(decodedJson);
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const String scrollSettingsFileName = "input_helper.settings.json";

class InputHelperModel extends ChangeNotifier {
  bool _isIterativeMatchInput = false;

  InputHelperModel({bool? isIterativeMatchInput})
      : _isIterativeMatchInput = isIterativeMatchInput ?? false;

  factory InputHelperModel.fromJson(Map<String, dynamic> json) {
    bool isIterativeMatchInput = json['isIterativeMatchInput'];
    return InputHelperModel(isIterativeMatchInput: isIterativeMatchInput);
  }

  Map<String, dynamic> toJson() {
    return {'isIterativeMatchInput': _isIterativeMatchInput};
  }

  bool isIterativeMatchInput() => _isIterativeMatchInput;

  void setIterativeMatchInput(bool value) {
    _isIterativeMatchInput = value;
    _writeData();
    notifyListeners();
  }

  Future<void> _writeData() async {
    final String path = (await getApplicationSupportDirectory()).path;
    final String jsonPath = p.join(path, scrollSettingsFileName);
    final File jsonFile = File(jsonPath);

    jsonFile.writeAsStringSync(jsonEncode(toJson()));
  }
}

Future<InputHelperModel> getInitialInputHelperModel() async {
  final String settingsDirectory =
      (await getApplicationSupportDirectory()).path;
  final String jsonPath = p.join(settingsDirectory, scrollSettingsFileName);
  final File jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    final InputHelperModel model = InputHelperModel();
    await model._writeData();
    return model;
  }

  final String jsonString = jsonFile.readAsStringSync();
  final dynamic decodedJson = jsonDecode(jsonString);

  return InputHelperModel.fromJson(decodedJson);
}

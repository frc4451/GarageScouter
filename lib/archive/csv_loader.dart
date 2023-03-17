/// This was initially derived from a template for File IO I found on Medium,
/// however, the code they provided was fairly unmaintainable when I started
/// building out custom CSV File IO and async management. So, I started from
/// scratch in the v2 file.
///
/// This is mostly just for our education.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/utils/dataframe_helpers.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path/path.dart' as p;

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

const List<String> kAllowedExtensions = ["csv"];

class CsvTestPage extends StatefulWidget {
  const CsvTestPage({super.key});

  @override
  State<CsvTestPage> createState() => _CsvTestPageState();
}

class _CsvTestPageState extends State<CsvTestPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String? _fileName;
  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  // String? _extension;
  bool _isLoading = false;
  bool _userAborted = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.custom;
  DataFrame df = DataFrame([]);
  TextEditingController _controller = TextEditingController();

  void kSuccessMessage(File value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("Successfully wrote file ${value.path}")));
  }

  void kFailureMessage(error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(error.toString())));
  }

  void _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: kAllowedExtensions,
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      _userAborted = _paths == null;
      _directoryPath = "";
    });
  }

  void _clearCachedFiles() async {
    _resetState();
    try {
      bool? result = await FilePicker.platform.clearTemporaryFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result! ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectFolder() async {
    _resetState();
    try {
      String? path = await FilePicker.platform.getDirectoryPath();
      setState(() {
        _paths = [];
        _directoryPath = path;
        _userAborted = path == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showContentsOfFile() async {
    final String filename = _fileName ?? "";
    final String directory = _directoryPath ?? "";

    if (filename.isNotEmpty) {
      _paths?.forEach((element) async {
        if (element.path != null) {
          String elementPath = element.path ?? "";
          listDataFromCSV(elementPath);
        }
      });
    } else if (directory.isNotEmpty) {
      df = await joinDataFramesFromDirectory(directory);
    }
  }

  Future<void> _saveFile() async {
    _resetState();
    try {
      File resultingFile = await createCSVFromDataFrame(df);
      String? fileName = await getNewFilePath(resultingFile);
      await copyFileToNewPath(resultingFile, fileName).then(kSuccessMessage);

      setState(() {
        _saveAsFileName = "";
        _userAborted = fileName == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logException(String message) {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("This is the second page"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              // Padding(
              // padding: const EdgeInsets.only(top: 20.0),
              // child:
              // DropdownButton<FileType>(
              //     hint: const Text('LOAD PATH FROM'),
              //     value: _pickingType,
              //     items: FileType.values
              //         .map((fileType) => DropdownMenuItem<FileType>(
              //               value: fileType,
              //               child: Text(fileType.toString()),
              //             ))
              //         .toList(),
              //     onChanged: (value) => setState(() {
              //           _pickingType = value!;
              //           if (_pickingType != FileType.custom) {
              //             _controller.text = _extension = '';
              //           }
              //         })),
              // ),
              // ConstrainedBox(
              //   constraints: const BoxConstraints.tightFor(width: 100.0),
              //   child: _pickingType == FileType.custom
              //       ? TextFormField(
              //           maxLength: 15,
              //           autovalidateMode: AutovalidateMode.always,
              //           controller: _controller,
              //           decoration: const InputDecoration(
              //             labelText: 'File extension',
              //           ),
              //           keyboardType: TextInputType.text,
              //           textCapitalization: TextCapitalization.none,
              //         )
              //       : const SizedBox(),
              // ),
              // ConstrainedBox(
              //   constraints: const BoxConstraints.tightFor(width: 200.0),
              //   child: SwitchListTile.adaptive(
              //     title: const Text(
              //       'Pick multiple files',
              //       textAlign: TextAlign.right,
              //     ),
              //     onChanged: (bool value) => setState(() => _multiPick = value),
              //     value: _multiPick,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _pickFiles(),
                      child: const Text('Pick files'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _selectFolder(),
                      child: const Text('Pick folder'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _saveFile(),
                      child: const Text('Save file'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showContentsOfFile(),
                      child: const Text('Show contents of file'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _clearCachedFiles(),
                      child: const Text('Clear temporary files'),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (BuildContext context) => _isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: CircularProgressIndicator(),
                      )
                    : _userAborted
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'User has aborted the dialog',
                            ),
                          )
                        : _directoryPath != null
                            ? ListTile(
                                title: const Text('Directory path'),
                                subtitle: Text(_directoryPath!),
                              )
                            : _paths != null
                                ? Container(
                                    padding:
                                        const EdgeInsets.only(bottom: 30.0),
                                    height: MediaQuery.of(context).size.height *
                                        0.50,
                                    child: Scrollbar(
                                        child: ListView.separated(
                                      itemCount:
                                          _paths != null && _paths!.isNotEmpty
                                              ? _paths!.length
                                              : 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final bool isMultiPath =
                                            _paths != null &&
                                                _paths!.isNotEmpty;
                                        // ignore: prefer_interpolation_to_compose_strings
                                        final String name = 'File $index: ' +
                                            (isMultiPath
                                                ? _paths!
                                                    .map((e) => e.name)
                                                    .toList()[index]
                                                : _fileName ?? '...');
                                        final path = kIsWeb
                                            ? null
                                            : _paths!
                                                .map((e) => e.path)
                                                .toList()[index]
                                                .toString();

                                        return ListTile(
                                          title: Text(
                                            name,
                                          ),
                                          subtitle: Text(path ?? ''),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(),
                                    )),
                                  )
                                : _saveAsFileName != null
                                    ? ListTile(
                                        title: const Text('Save file'),
                                        subtitle: Text(_saveAsFileName!),
                                      )
                                    : const SizedBox(),
              ),
            ],
          ),
        ));
  }
}

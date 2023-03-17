import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

import '../components/layout/padded_list_element.dart';
import '../utils/dataframe_helpers.dart';
import '../utils/file_io_helpers.dart';

class CsvManagerPage extends StatefulWidget {
  const CsvManagerPage({super.key});

  @override
  State<CsvManagerPage> createState() => _CsvManagerPageState();
}

/// Second Attempt at making a CSV Management Panel
/// Still very much a work in progress.
class _CsvManagerPageState extends State<CsvManagerPage> {
  // Required State Variables
  final String title = "CSV Loading/Management Panel";

  // Optional State Variables
  List<PlatformFile>? paths;
  String? directory;

  // Asynchronous function to grab a list of files using the OS's native
  // File Explorer and store it for later usage.
  Future<void> pickFiles() async {
    try {
      List<PlatformFile>? selectedPaths = (await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowMultiple: true,
              onFileLoading: (FilePickerStatus status) => print(status),
              allowedExtensions: ["csv"]))
          ?.files;

      if (selectedPaths!.isNotEmpty) {
        kSuccessMessage(
            "Successfully selected files :: ${getFormattedPaths()}");
      }

      setState(() {
        paths = selectedPaths;
        directory = "";
      });
    } on PlatformException catch (e) {
      kFailureMessage(e.toString());
    } catch (e) {
      kFailureMessage("User aborted File Window");
    }

    if (!mounted) {
      return;
    }
  }

  // Uses the OS's native File Explorer tool to select a directory and have it
  // displayed for the User to see what files can be read.
  void pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory!.isNotEmpty) {
        kSuccessMessage("Succesfully read directory :: $directory");
      }

      setState(() {
        paths = [];
        directory = selectedDirectory;
      });
    } catch (e) {
      kFailureMessage("User aborted File Window");
    }

    if (!mounted) {
      return;
    }
  }

  void showContents() async {
    if (directory != null && directory!.isNotEmpty) {
      DataFrame df = await joinDataFramesFromDirectory(directory!);
      String data = convertDataFrameToString(df);
      if (data.isEmpty) {
        kFailureMessage("This hasn't been implemented yet.");
      }
    } else {
      kFailureMessage("This hasn't been implemented yet.");
    }
    return;

    if (directory == null && paths == null) {
      kFailureMessage(
          "Open either a series of files or a directory to read all files.");
    }

    if (directory != null && directory!.isNotEmpty) {
    } else if (paths != null && paths!.isNotEmpty) {}
  }

  void combineResults() async {
    if (directory != null && directory!.isNotEmpty) {
      try {
        DataFrame df = await joinDataFramesFromDirectory(directory!);
        File createdFile = await createCSVFromDataFrame(df);
        File finalFile = await saveFileToDevice(createdFile);
        kSuccessMessage(
            "Successfully saved results from CSV directory files to ${finalFile.path}");
      } catch (e) {
        kFailureMessage(e.toString());
      }
    } else if (paths != null && paths!.isNotEmpty) {
      try {
        DataFrame df = await joinDataFramesFromListOfPaths(paths!);
        File createdFile = await createCSVFromDataFrame(df);
        File finalFile = await saveFileToDevice(createdFile);
        kSuccessMessage(
            "Successfully saved results from selected files to ${finalFile.path}");
      } catch (e) {
        kFailureMessage(e.toString());
      }
    } else {
      kFailureMessage(
          "Check your inputs and make sure you selected files or a directory.");
    }
  }

  void resetFiles() async {
    try {
      bool? result = await FilePicker.platform.clearTemporaryFiles();
      if (result!) {
        kSuccessMessage("Successfully cleared cached files");
      }
    } catch (e) {
      kFailureMessage(e.toString());
    }

    resetState();
  }

  void resetState() {
    setState(() {
      paths = null;
      directory = null;
    });
  }

  // Helper method to join all paths to a single CSV list
  String getFormattedPaths() =>
      paths != null ? paths!.toList().map((e) => e.name).join(", ") : "";

  String getFormattedDirectory() => directory ?? "";

  void kSuccessMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Center(
          child: Text(message),
        )));
  }

  void kFailureMessage(String error) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Center(
            child: Text(
          error,
        ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(title),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  PaddedListElement(
                      isFirstElement: true,
                      labelText:
                          "Pick files that the user wants to use for the CSV Manager",
                      buttonText: "Pick Files",
                      onPressed: pickFiles),
                  Text(getFormattedPaths()),
                  PaddedListElement(
                      labelText:
                          "Pick directory to include all CSVs you want to include",
                      buttonText: "Pick Directory",
                      onPressed: pickDirectory),
                  Text(getFormattedDirectory()),
                  PaddedListElement(
                      labelText:
                          "Display the contents of all CSVs that have been selected",
                      buttonText: "Show Contents",
                      onPressed: showContents),
                  PaddedListElement(
                      labelText:
                          "Combine the results from all CSVs specified and return a single CSV",
                      buttonText: "Combine Results",
                      onPressed: combineResults),
                  PaddedListElement(
                      labelText:
                          "Reset files or directory that have been selected",
                      buttonText: "Reset Manager",
                      onPressed: resetFiles),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

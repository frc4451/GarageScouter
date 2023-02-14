import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/forms/choice_helpers.dart';
import 'package:robotz_garage_scouting/components/forms/question_label.dart';
import 'package:robotz_garage_scouting/components/forms/radio_helpers.dart';
import 'package:robotz_garage_scouting/components/forms/text_helpers.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';
import 'package:robotz_garage_scouting/utils/dataframe_helpers.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class FormsTest extends StatefulWidget {
  const FormsTest({super.key});

  @override
  State<FormsTest> createState() => _FormsTestState();
}

class _FormsTestState extends State<FormsTest> {
  void _navigateToSecondPage() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const MyHomePage(
              title: 'Home page',
            )));
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final textEditingController = TextEditingController();

  final double questionFontSize = 10;

  // https://docs.flutter.dev/cookbook/forms/focus
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  void kSuccessMessage(File value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("Successfully wrote file ${value.path}")));
  }

  void kFailureMessage(error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(error.toString())));
  }

  /// Handles form submission
  Future<void> submitForm() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    _formKey.currentState?.save();

    DataFrame df = convertFormStateToDataFrame(_formKey.currentState!);

    // adds timestamp
    df.addSeries(Series("timestamp", [DateTime.now().toString()]));
    // df["timestamp"] = DateTime.now()

    final String teamNumber =
        _formKey.currentState!.value["team_number"] ?? "no_team_number";

    final String filePath = await generateUniqueFilePath(
        extension: "csv", prefix: "${teamNumber}_pit_scouting");

    final File file = File(filePath);

    try {
      File finalFile = await file.writeAsString(convertDataFrameToString(df));

      saveFileToDevice(finalFile)
          .then(kSuccessMessage)
          .catchError(kFailureMessage);
      // if (isDesktopPlatform()) {
      //   saveFilesForDesktopApplication(finalFile)
      //       .then(kSuccessMessage)
      //       .catchError(kFailureMessage);
      // } else if (isMobilePlatform()) {
      //   saveFilesForMobileApplication(finalFile)
      //       .then(kSuccessMessage)
      //       .catchError(kFailureMessage);
      // } else {
      //   throw Exception("Functionality currently not supported");
      // }
    } on Exception catch (_, exception) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
        log(exception.toString(), name: "ERROR");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const SliverAppBar(
        pinned: true,
        title: Text("Testing form inputs"),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            FormBuilder(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const QuestionLabel(text: "What is the Team Name?"),
                    FormBuilderTextField(
                      name: "team_name",
                      decoration: const InputDecoration(
                          labelText: "Team Name", prefixIcon: Icon(Icons.abc)),
                    ),
                    const QuestionLabel(text: "What is the Team Number?"),
                    FormBuilderTextField(
                      name: "team_number",
                      decoration: const InputDecoration(
                          labelText: "Team Number",
                          prefixIcon: Icon(Icons.numbers)),
                    ),
                    const ChipHelpers(
                        question: "What kind of drive train do they use?",
                        name: "drive_train",
                        labelText: "Drive Train",
                        prefixIcon: Icons.drive_eta,
                        options: ["Tank Drive", "West Coast", "Swerve Drive"]),
                    const FullYesOrNoField(
                        name: "has_arm", question: "Do they have an arm?"),
                    const FullYesOrNoField(
                        name: "has_intake",
                        question: "Do they have an intake system?"),
                    const FullYesOrNoField(
                        name: "can_charge_autonomous",
                        question:
                            "Are they able to use the charge station in autonomous?"),
                  ],
                )),
            IconButton(
                onPressed: submitForm, icon: const Icon(Icons.send_rounded))
          ],
        ),
      )
    ]));
  }
}

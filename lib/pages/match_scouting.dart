import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_auto.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_endgame.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_initial.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_summary.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_teleop.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';

import 'package:robotz_garage_scouting/utils/dataframe_helpers.dart';
import 'package:robotz_garage_scouting/utils/enums.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key});

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingPageState();
}

class _MatchScoutingPageState extends State<MatchScoutingPage> {
  final String title = "Match Scouting Form";
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  final int durationMilliseconds = 300;

  // Widgets we plan to show during the match. Swipe or click nav buttons as needed.
  final List<Widget> pages = [];

  // We can't rely on _controller.page because the page is not fully updated
  // until _after_ the page has transitioned. Because of that, we need an
  // internally managed "page state" to know when we need to submit the form.
  int _currentPage = 0;

  void _kSuccessMessage(File value) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Successfully wrote file ${value.path}",
          textAlign: TextAlign.center,
        )));
  }

  void _kFailureMessage(error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        )));
  }

  /// Handles form submission
  Future<void> _submitForm() async {
    bool isValid = _formKey.currentState!.saveAndValidate();

    if (!isValid) {
      _kFailureMessage(
          "Form has bad inputs. Start with the Initial page and verify inputs.");
      _resetPage();
      return;
    }

    // Help clean up the input by removing spaces on both ends of the string
    Map<String, dynamic> trimmedInputs =
        _formKey.currentState!.value.map((key, value) {
      return (value is String)
          ? MapEntry(key, value.trim().replaceAll(",", ""))
          : MapEntry(key, value);
    });

    _formKey.currentState?.patchValue(trimmedInputs);
    _formKey.currentState?.save();

    DataFrame df = convertFormStateToDataFrame(_formKey.currentState!);

    String timestamp = DateTime.now().toString();
    df = df.addSeries(Series("timestamp", [timestamp]));

    final String matchNumber = df["match_number"].data.first.toString();
    final String teamNumber = df["team_number"].data.first.toString();
    final String alliance = df["team_alliance"].data.first.toString();

    final String filePath = await generateUniqueFilePath(
        extension: "csv",
        prefix: "match_${matchNumber}_${alliance}_$teamNumber",
        timestamp: timestamp);

    final File file = File(filePath);

    try {
      File finalFile = await file.writeAsString(convertDataFrameToString(df));

      saveFileToDevice(finalFile).then((File file) {
        _clearForm();
        _kSuccessMessage(file);
      }).catchError(_kFailureMessage);
    } on Exception catch (_, exception) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
        log(exception.toString(), name: "ERROR");
      }
    }
  }

  /// Handles Previous Page functionality for desktop/accessibility
  void _prevPage() {
    _onPageChanged(_controller.page!.toInt(), direction: PageDirection.left);
  }

  /// Handles Next Page functionality for desktop/accessibility
  void _nextPage() {
    _onPageChanged(_controller.page!.toInt(), direction: PageDirection.right);
  }

  void _resetPage() {
    setState(() {
      _currentPage = _controller.initialPage;
      _controller.animateToPage(_currentPage,
          duration: Duration(milliseconds: durationMilliseconds),
          curve: Curves.ease);
    });
  }

  /// Handles page change events, but optionally accepts a "direction" parameter to allow
  /// the developer to simulate a new page change for the PageViewController.
  ///
  /// If a "direction" is not provided, then we just assign the pageNumber the swiping
  /// action gave us from the PageView component.
  ///
  /// We also check for when a user hits "previous" and prevent them from overflowing
  /// the scroll and hiding the form. We don't check for the last page because it changes
  /// to "Submit".
  void _onPageChanged(int pageNumber,
      {PageDirection direction = PageDirection.none}) {
    setState(() {
      _currentPage = pageNumber;
      if (direction != PageDirection.none &&
          (pageNumber + direction.value) >= 0) {
        _currentPage = pageNumber + direction.value;
        _controller.animateToPage(_currentPage,
            duration: Duration(milliseconds: durationMilliseconds),
            curve: Curves.ease);
      }
    });
  }

  /// This is a fairly hacky workaround to work around form fields that aren't
  /// immediately shown on the screen. For Match Scouting, the fields on pages
  /// that aren't active. We save, then reset using the based form management,
  /// but we also patch all values with null values to forcibly reset the form state.
  Future<void> _clearForm() async {
    _formKey.currentState?.save();
    Map<String, dynamic> blanks =
        convertListToDefaultMap(_formKey.currentState?.value.keys);
    await context.read<RetainInfoModel>().setMatchScouting(blanks);
    setState(() {
      _formKey.currentState?.reset();
      _formKey.currentState?.patchValue(blanks);
      _formKey.currentState?.save();
      _resetPage();
    });
  }

  /// We override initState so that we can do two things:
  /// 1. Find the closest parent that reads RetainInfoModel
  /// 2. Read the matchScouting data and pass the data to all
  ///    pages in the form to populate initialValues.
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> matchData =
        context.read<RetainInfoModel>().matchScouting();
    pages.addAll([
      MatchInitialScreen(matchData: matchData),
      MatchAutonomousScreen(matchData: matchData),
      MatchTeleopScreen(matchData: matchData),
      MatchEndgameScreen(matchData: matchData),
      MatchSummaryScreen(matchData: matchData)
    ]);
  }

  /// We use the deactivate life-cycle hook since State is available and we can
  /// read it to optionally save to the "RetainInfoModel" object if the user has
  /// specified they want to retain info in the form when they back out.
  @override
  void deactivate() {
    RetainInfoModel model = context.watch<RetainInfoModel>();
    if (model.doesRetainInfo()) {
      _formKey.currentState?.save();
      model.setMatchScouting(_formKey.currentState!.value);
    }
    super.deactivate();
  }

  /// Clean up the component, but also the FormBuilderController
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RetainInfoModel, ScrollModel>(
        builder: (context, retain, scroll, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Match Scouting",
              textAlign: TextAlign.center,
            ),
            actions: retain.doesRetainInfo()
                ? [
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                    title:
                                        const Text("Clear Match Scouting Data"),
                                    content: const Text(
                                        "Are you sure you want to clear Match Scouting Data?\n\n"
                                        "Your temporary data will also be cleared."),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          _clearForm();
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Confirm"),
                                      )
                                    ]));
                      },
                      icon: const Icon(Icons.clear),
                      tooltip: "Clear Match Scouting Form",
                    )
                  ]
                : [],
          ),
          body: FormBuilder(
              key: _formKey,
              // NOTE: You must implement AutomaticKeepAliveClientMixin in every
              // page component you plan to show in the PageView, or else you
              // will lose your FormValidation support
              child: PageView(
                physics: scroll.canSwipe()
                    ? const NeverScrollableScrollPhysics()
                    : null,
                controller: _controller,
                onPageChanged: _onPageChanged,
                children: pages,
              )),
          persistentFooterButtons: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: _prevPage, child: const Text("Previous")),
                _currentPage >= pages.length - 1
                    ? ElevatedButton(
                        onPressed: _submitForm, child: const Text("Submit"))
                    : ElevatedButton(
                        onPressed: _nextPage, child: const Text("Next")),
              ],
            )
          ]);
    });
  }
}

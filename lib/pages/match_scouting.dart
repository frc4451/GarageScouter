import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_auto.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_endgame.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_initial.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_summary.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_teleop.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';

import '../utils/dataframe_helpers.dart';

enum PageDirection { left, right, none }

extension PageExtension on PageDirection {
  int get value {
    switch (this) {
      case PageDirection.left:
        return -1;
      case PageDirection.right:
        return 1;
      case PageDirection.none:
        return 0;
    }
  }
}

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
  final List<Widget> pages = const [
    MatchInitialScreen(),
    MatchAutonomousScreen(),
    MatchTeleopScreen(),
    MatchEndgameScreen(),
    MatchSummaryScreen()
  ];

  // We can't rely on _controller.page because the page is not fully updated
  // until _after_ the page has transitioned. Because of that, we need an
  // internally managed "page state" to know when we need to submit the form.
  int _currentPage = 0;

  void _kSuccessMessage(File value) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("Successfully wrote file ${value.path}")));
  }

  void _kFailureMessage(error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(error.toString())));
  }

  /// Handles form submission
  Future<void> _submitForm() async {
    bool isValid = _formKey.currentState!.saveAndValidate();

    if (!isValid) {
      _kFailureMessage(
          "Form is missing inputs. Check Initial page and verify inputs.");
      _resetPage();
      return;
    }

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

      saveFileToDevice(finalFile)
          .then(_kSuccessMessage)
          .catchError(_kFailureMessage);
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

  /// Clean up the component, but also the FormBuilderController
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Match Scouting")),
        body: FormBuilder(
            key: _formKey,
            // NOTE: You must implement AutomaticKeepAliveClientMixin in every
            // page component you plan to show in the PageView, or else you
            // will lose your FormValidation support
            child: PageView(
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
  }
}

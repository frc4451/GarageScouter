import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/input_helper_model.dart';
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

class _MatchScoutingPageState extends State<MatchScoutingPage>
    with SingleTickerProviderStateMixin {
  final String title = "Match Scouting Form";
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  final int durationMilliseconds = 300;

  // Widgets we plan to show during the match. Swipe or click nav buttons as needed.
  final List<Widget> pages = [];

  late TabController _tabController;

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
    bool isValid = _formKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      _kFailureMessage(
          "Form has bad inputs. Start with the Initial page and verify inputs.");
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

      saveFileToDevice(finalFile).then((File file) {
        _clearForm(isSubmission: true);
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
    _onPageChanged(_tabController.index, direction: PageDirection.left);
  }

  /// Handles Next Page functionality for desktop/accessibility
  void _nextPage() {
    _onPageChanged(_tabController.index, direction: PageDirection.right);
  }

  void _resetPage() {
    setState(() {
      _currentPage = 0;
      _tabController.animateTo(_currentPage);
      // _currentPage = _controller.initialPage;
      // _controller.animateToPage(_currentPage,
      //     duration: Duration(milliseconds: durationMilliseconds),
      //     curve: Curves.ease);
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
        _tabController.animateTo(_currentPage);
      }
    });
  }

  /// This is a fairly hacky workaround to work around form fields that aren't
  /// immediately shown on the screen. For Match Scouting, the fields on pages
  /// that aren't active. We save, then reset using the based form management,
  /// but we also patch all values with null values to forcibly reset the form state.
  Future<void> _clearForm({isSubmission = false}) async {
    _formKey.currentState?.save();

    Map<String, dynamic> initialValues =
        createEmptyFormState(_formKey.currentState?.value ?? {});

    if (context.read<InputHelperModel>().isIterativeMatchInput()) {
      initialValues['team_alliance'] =
          _formKey.currentState?.value['team_alliance'];

      initialValues['team_position'] =
          _formKey.currentState?.value['team_position'];

      initialValues['match_number'] =
          (int.parse(_formKey.currentState?.value['match_number']) +
                  (isSubmission ? 1 : 0))
              .toString();
    }

    await context.read<RetainInfoModel>().setMatchScouting(initialValues);
    setState(() {
      _formKey.currentState?.patchValue(initialValues);
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

    _tabController = TabController(length: pages.length, vsync: this);
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
    _tabController.dispose();
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
                                      OutlinedButton(
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
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    onTap: _onPageChanged,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    tabs: const [
                      Text('Initial'),
                      Text('Auto'),
                      Text('Teleop'),
                      Text('End'),
                      Text('Summary')
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: pages,
                    ),
                  )
                ],
              )),

          // NOTE: You must implement AutomaticKeepAliveClientMixin in every
          // page component you plan to show in the PageView, or else you
          // will lose your FormValidation support
          // child: PageView(
          //   physics: scroll.canSwipe()
          //       ? const NeverScrollableScrollPhysics()
          //       : null,
          //   controller: _controller,
          //   onPageChanged: _onPageChanged,
          //   children: pages,
          // )),
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

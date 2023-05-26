import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/models/input_helper_model.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_auto.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_initial.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_summary.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_endgame.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_teleop.dart';

import 'package:robotz_garage_scouting/utils/enums.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key});

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingPageState();
}

class _MatchScoutingPageState extends State<MatchScoutingPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  final int durationMilliseconds = 300;

  // Widgets we plan to show during the match. Swipe or click nav buttons as needed.
  final List<Widget> pages = [];

  late TabController _tabController;
  late Isar _isar;

  // We can't rely on _controller.page because the page is not fully updated
  // until _after_ the page has transitioned. Because of that, we need an
  // internally managed "page state" to know when we need to submit the form.
  int _currentPage = 0;

  /// Handles form submission
  Future<void> _submitForm() async {
    final bool isValid = _formKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      errorMessageSnackbar(context,
          "Form has bad inputs. Start with the Initial page and verify inputs.");
      _resetPage();
      return;
    }

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    String timestamp = DateTime.now().toString();
    state['timestamp'] = timestamp;

    final String matchNumber = state["match_number"].toString();
    final String teamNumber = state["team_number"].toString();
    final String alliance = state["team_alliance"].toString();

    // final String filePath = await generateUniqueFilePath(
    //     extension: "csv",
    //     prefix: "match_${matchNumber}_${alliance}_$teamNumber",
    //     timestamp: timestamp);

    // try {
    //   if (kIsWeb) {
    //     saveFileFromWeb(
    //             filePath: filePath, contents: convertMapStateToString(state))
    //         .then((File value) {
    //       _clearForm(isSubmission: true);
    //       saveFileSnackbar(context, value);
    //     }).catchError((exception) {
    //       errorMessageSnackbar(context, exception);
    //     });

    //     return;
    //   }
    // final File file = File(filePath);
    // final File finalFile =
    //     await file.writeAsString(convertMapStateToString(state));

    // saveFileToDevice(finalFile).then((File file) {
    //   _clearForm(isSubmission: true);
    //   saveFileSnackbar(context, file);
    // }).catchError((error) {
    //   errorMessageSnackbar(context, error);
    // });

    MatchScoutingEntry entry = MatchScoutingEntry()
      ..teamNumber = int.tryParse(teamNumber)
      ..matchNumber = int.tryParse(matchNumber)
      ..alliance =
          alliance.toLowerCase() == "red" ? TeamAlliance.red : TeamAlliance.blue
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = false;

    _isar.writeTxn(() => _isar.matchScoutingEntrys.put(entry)).then((value) {
      _clearForm(isSubmission: true);
      successMessageSnackbar(context, "Saved data to Isar, Index $value");
    }).catchError((error) {
      errorMessageSnackbar(context, error);
    });
    // }
    // on Exception catch (_, exception) {
    //   if (mounted) {
    //     errorMessageSnackbar(context, exception);
    //   }
    // }
  }

  /// Handles Previous Page functionality for desktop/accessibility
  void _prevPage() {
    _onPageChanged(_tabController.index, direction: PageDirection.left);
  }

  /// Handles Next Page functionality for desktop/accessibility
  void _nextPage() {
    _onPageChanged(_tabController.index, direction: PageDirection.right);
  }

  /// Handles page resets
  void _resetPage() {
    setState(() {
      _currentPage = 0;
      _tabController.animateTo(_currentPage);
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

  /// When we clear the form, we need to check to see if the form
  /// is a submission, and if `iterative match input` was enabled
  /// in the settings. If iterative match input is enabled we need
  /// to make sure that the page increments the match number as well
  /// as retains team alliance and position for the scouter. If the
  /// form was _not_ a submission and instead a form clear, then we
  /// just retain the previous match number
  Future<void> _clearForm({isSubmission = false}) async {
    _formKey.currentState?.save();

    Map<String, dynamic> patchedValues = {};

    if (context.read<InputHelperModel>().isIterativeMatchInput()) {
      patchedValues['team_alliance'] =
          _formKey.currentState?.value['team_alliance'];

      patchedValues['team_position'] =
          _formKey.currentState?.value['team_position'];

      patchedValues['match_number'] =
          (int.parse(_formKey.currentState?.value['match_number'] ?? "0") +
                  (isSubmission ? 1 : 0))
              .toString();
    }

    setState(() {
      _formKey.currentState!.fields.forEach((key, field) {
        field.didChange(null);
      });
      _formKey.currentState?.save();
      _formKey.currentState?.reset();

      context.read<RetainInfoModel>().resetMatchScouting();
      _formKey.currentState?.patchValue(patchedValues);
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
    Map<String, dynamic> matchData = {};
    // context.read<RetainInfoModel>().matchScouting();
    pages.addAll([
      MatchInitialScreen(matchData: matchData),
      MatchAutonomousScreen(matchData: matchData),
      MatchTeleopScreen(matchData: matchData),
      MatchEndgameScreen(matchData: matchData),
      MatchSummaryScreen(matchData: matchData)
    ]);

    _tabController = TabController(length: pages.length, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _currentPage = _tabController.index;
      });
    });

    _isar = context.read<IsarModel>().isar;
  }

  /// We safely save the state of the form when the user pops the Widget from
  /// the Widget Tree. Assuming that we're using imperative routing, this should
  /// pop from the widget tree.
  ///
  /// The only form validation we do is check if the `team_number` and
  /// `match_number` form field are not null, and if it is not null, save
  /// the entry as a draft.
  Future<bool> _onWillPop() async {
    _formKey.currentState?.save();

    final Map<String, dynamic> state = Map.from(_formKey.currentState!.value);
    final int? teamNumber = int.tryParse(state['team_number'] ?? "");
    final int? matchNumber = int.tryParse(state['match_number'] ?? "");
    final String? alliance = state['team_alliance'];

    if (state.isEmpty ||
        teamNumber == null ||
        matchNumber == null ||
        alliance == null) {
      return true;
    }

    MatchScoutingEntry entry = MatchScoutingEntry()
      ..teamNumber = teamNumber
      ..matchNumber = matchNumber
      ..alliance = alliance.toLowerCase() == "red"
          ? TeamAlliance.red
          : alliance.toLowerCase() == "blue"
              ? TeamAlliance.blue
              : TeamAlliance.unassigned
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = true;

    if (entry.teamNumber == null || entry.matchNumber == null) {
      return true;
    }

    await _isar
        .writeTxn(() => _isar.matchScoutingEntrys.put(entry))
        .then((value) {
      successMessageSnackbar(context, "Successfully saved Draft to Isar.");
    }).catchError((error) {
      errorMessageSnackbar(context, error);
    });

    return true;
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
          body: WillPopScope(
              onWillPop: _onWillPop,
              child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Consumer<ThemeModel>(
                        builder: (context, model, _) => IgnorePointer(
                            ignoring: true,
                            child: TabBar(
                              controller: _tabController,
                              labelColor: model.getLabelColor(),
                              indicatorColor: model.getLabelColor(),
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
                            )),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: pages,
                        ),
                      )
                    ],
                  ))),
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

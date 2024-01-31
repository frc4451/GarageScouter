import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:garagescouter/constants/platform_check.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/models/input_helper_model.dart';
import 'package:garagescouter/models/scroll_model.dart';
import 'package:garagescouter/models/theme_model.dart';
import 'package:garagescouter/pages/match_scouting/match_auto.dart';
import 'package:garagescouter/pages/match_scouting/match_initial.dart';
import 'package:garagescouter/pages/match_scouting/match_summary.dart';
import 'package:garagescouter/pages/match_scouting/match_endgame.dart';
import 'package:garagescouter/pages/match_scouting/match_teleop.dart';

import 'package:garagescouter/utils/enums.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key, this.uuid = ""});
  final String uuid;

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
  late IsarModel _isarModel;
  late Map<String, dynamic> _initialValue;

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

    MatchScoutingEntry entry = await _isarModel.getMatchDataByUUID(widget.uuid);

    bool wasDraft = entry.isDraft ?? false;

    entry
      ..teamNumber = int.tryParse(teamNumber)
      ..matchNumber = int.tryParse(matchNumber)
      ..alliance =
          alliance.toLowerCase() == "red" ? TeamAlliance.red : TeamAlliance.blue
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = false;

    _isarModel.putScoutingData(entry).then((value) {
      _clearForm(isSubmission: true);
      successMessageSnackbar(context, "Saved data to Isar, Index $value");

      if (wasDraft) {
        context.pop();
      }
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
    pages.addAll([
      const MatchInitialScreen(),
      const MatchAutonomousScreen(),
      const MatchTeleopScreen(),
      const MatchEndgameScreen(),
      const MatchSummaryScreen()
    ]);

    _tabController = TabController(length: pages.length, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _currentPage = _tabController.index;
      });
    });

    _isarModel = context.read<IsarModel>();

    MatchScoutingEntry entry = _isarModel.getMatchDataByUUIDSync(widget.uuid);

    _initialValue = decodeJsonFromB64(entry.b64String ?? "");
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

    MatchScoutingEntry entry = await _isarModel.getMatchDataByUUID(widget.uuid);

    String currentb64String = encodeJsonToB64(state, urlSafe: true);

    if (currentb64String == entry.b64String) {
      return true;
    }

    bool? keepDraft = await canSaveDraft(context, exists: entry.isDraft);

    // This can be null if the user clicks outside of the notification dialog.
    // When a user clicks outside of a dialog, it's assumed the user doesn't
    // want to leave the screen.
    if (keepDraft == null) {
      return false;
    }

    entry
      ..teamNumber = teamNumber
      ..matchNumber = matchNumber
      ..alliance = alliance.toLowerCase() == "red"
          ? TeamAlliance.red
          : alliance.toLowerCase() == "blue"
              ? TeamAlliance.blue
              : TeamAlliance.unassigned
      ..b64String = currentb64String
      ..isDraft = true;

    if (keepDraft) {
      _isarModel.putScoutingData(entry).then((value) {
        _clearForm();
        successMessageSnackbar(context, "Saved draft to Isar, Index $value");
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }

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
    return Consumer<ScrollModel>(builder: (context, scroll, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Match Scouting"),
            centerTitle: true,
          ),
          // We're aware that WillPopScope is deprecated, however, as
          // of writing, we do not have an asynchronous way to handle user
          // dialogs with `PopScope` or `PopEntry` without a dedicated
          // NavigatorState. Please follow the following GitHub discussion
          // in case this changes.
          // https://github.com/flutter/flutter/issues/138614
          // body: WillPopScope(
          //     onWillPop: _onWillPop,
          body: PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) {
                  return;
                }

                final NavigatorState navigator = Navigator.of(context);
                final bool shouldPop = await _onWillPop();

                if (shouldPop) {
                  navigator.pop();
                }
              },
              // onWillPop: _onWillPop,
              child: FormBuilder(
                  initialValue: _initialValue,
                  key: _formKey,
                  child: Column(
                    children: [
                      Consumer<ThemeModel>(
                        builder: (context, model, _) => IgnorePointer(
                            ignoring: isMobilePlatform(),
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
                              tabAlignment: TabAlignment.center,
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

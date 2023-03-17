import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/page_widgets/super_scouting/super_initial.dart';
import 'package:robotz_garage_scouting/page_widgets/super_scouting/super_text_page.dart';
import 'package:robotz_garage_scouting/validators/custom_integer_validators.dart';
import 'package:robotz_garage_scouting/utils/dataframe_helpers.dart';
import 'package:robotz_garage_scouting/utils/enums.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';
import 'package:robotz_garage_scouting/validators/custom_text_validators.dart';

class SuperScoutingPage extends StatefulWidget {
  const SuperScoutingPage({super.key});

  @override
  State<SuperScoutingPage> createState() => _SuperScoutingPageState();
}

class _SuperScoutingPageState extends State<SuperScoutingPage> {
  final String title = "Match Scouting Form";
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  final int durationMilliseconds = 300;

  final int _maxLines = 5;
  final int _maxLength = 1024;

  // Widgets we plan to show during the match. Swipe or click nav buttons as needed.
  final List<Widget> pages = const [
    SuperScoutingInitialScreen(),
    SuperScoutingTextInputPage(
        label: "Effective Offense", name: "effective_offense"),
    SuperScoutingTextInputPage(
        label: "Effective Defense", name: "effective_defense"),
    SuperScoutingTextInputPage(
        label: "Ineffective Offense", name: "ineffective_offense"),
    SuperScoutingTextInputPage(
        label: "Ineffective Defense", name: "ineffective_defense"),
    SuperScoutingTextInputPage(
        label: "Counter Strategy Offense", name: "counter_strategy_offense"),
    SuperScoutingTextInputPage(
        label: "Counter Strategy Defense", name: "counter_strategy_defense"),
    SuperScoutingTextInputPage(label: "Final Notes", name: "final_notes"),
  ];

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
          "Form is missing inputs. Check Initial page and verify inputs.");
      _resetPage();
      return;
    }

    // Help clean up the input by removing spaces on both ends of the string
    Map<String, dynamic> trimmedInputs =
        _formKey.currentState!.value.map((key, value) {
      return (value is String)
          ? MapEntry(key, value.trim())
          : MapEntry(key, value);
    });

    _formKey.currentState?.patchValue(trimmedInputs);
    _formKey.currentState?.save();

    DataFrame df = convertFormStateToDataFrame(_formKey.currentState!);

    String timestamp = DateTime.now().toString();
    df = df.addSeries(Series("timestamp", [timestamp]));

    final String matchNumber = df["match_number"].data.first.toString();
    final String teamNumber = df["team_number"].data.first.toString();
    final String filePath = await generateUniqueFilePath(
        extension: "csv",
        prefix: "super_scouting_${matchNumber}_$teamNumber",
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

  /// We use the deactivate life-cycle hook since State is available and we can
  /// read it to optionally save to the "RetainInfoModel" object if the user has
  /// specified they want to retain info in the form when they back out.
  @override
  void deactivate() {
    RetainInfoModel model = context.watch<RetainInfoModel>();
    if (model.doesRetainInfo()) {
      _formKey.currentState?.save();
      model.setSuperScouting(_formKey.currentState!.value);
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
    return Consumer<RetainInfoModel>(builder: (context, retain, _) {
      final Map<String, dynamic> superScouting = retain.superScouting();
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Super Scouting",
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
                                      const Text("Clear Super Scouting Data"),
                                  content: const Text(
                                      "Are you sure you want to clear Super Scouting Data?\n\n"
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
                                      onPressed: () {
                                        _formKey.currentState!.reset();
                                        retain.setSuperScouting(
                                            <String, dynamic>{});
                                        Navigator.pop(context);
                                      },
                                      child: Text("Confirm"),
                                    )
                                  ]));
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: "Clear Super Scouting Form",
                  )
                ]
              : [],
        ),
        body: FormBuilder(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: "team_number",
                        initialValue: superScouting["team_number"],
                        decoration: const InputDecoration(
                            labelText: "Team Number",
                            prefixIcon: Icon(Icons.numbers)),
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.integer(),
                          CustomTextValidators.doesNotHaveCommas(),
                          CustomIntegerValidators.notNegative()
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      FormBuilderTextField(
                        name: "match_number",
                        initialValue: superScouting["match_number"],
                        decoration: const InputDecoration(
                            labelText: "Match Number",
                            prefixIcon: Icon(Icons.numbers)),
                        textInputAction: TextInputAction.done,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.integer(),
                          CustomTextValidators.doesNotHaveCommas(),
                          CustomIntegerValidators.notNegative()
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      // Text(),
                      FormBuilderTextField(
                        name: "effective_offense",
                        initialValue: superScouting["effective_offense"],
                        decoration: const InputDecoration(
                          labelText: "Effective Offensive Strategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "effective_defense",
                        initialValue: superScouting["effective_defense"],
                        decoration: const InputDecoration(
                          labelText: "Effective Defensive Strategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "ineffective_offense",
                        initialValue: superScouting["ineffective_offense"],
                        decoration: const InputDecoration(
                          labelText: "Ineffective Offensive Strategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "ineffective_defense",
                        initialValue: superScouting["ineffective_defense"],
                        decoration: const InputDecoration(
                          labelText: "Ineffective Defensive Strategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "counter_strategy_offense",
                        initialValue: superScouting["counter_strategy_offense"],
                        decoration: const InputDecoration(
                          labelText: "Offensive Counterstrategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "counter_strategy_defense",
                        initialValue: superScouting["counter_strategy_defense"],
                        decoration: const InputDecoration(
                          labelText: "Defensive Counterstrategies",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "final_notes",
                        initialValue: superScouting["final_notes"],
                        decoration: const InputDecoration(
                          labelText: "Final Notes",
                        ),
                        maxLength: _maxLength,
                        maxLines: _maxLines,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomTextValidators.doesNotHaveCommas(),
                        ]),
                      ),
                      ElevatedButton(
                          onPressed: _submitForm, child: const Text("Submit"))
                    ],
                  ),
                )
              ],
            )),
        // @deprecated, but kept here for future refactoring.
        // We may eventually go back to scrolling. or re-introduce it as an option.
        // NOTE: You must implement AutomaticKeepAliveClientMixin in every
        // page component you plan to show in the PageView, or else you
        // will lose your FormValidation support
        // child: Consumer<ScrollModel>(
        //     builder: (context, model, _) => PageView(
        //           physics: model.canSwipe()
        //               ? const NeverScrollableScrollPhysics()
        //               : null,
        //           controller: _controller,
        //           onPageChanged: _onPageChanged,
        //           children: pages,
        //         ))),
        // persistentFooterButtons: <Widget>[
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       ElevatedButton(
        //           onPressed: _prevPage, child: const Text("Previous")),
        //       _currentPage >= pages.length - 1
        //           ? ElevatedButton(
        //               onPressed: _submitForm, child: const Text("Submit"))
        //           : ElevatedButton(
        //               onPressed: _nextPage, child: const Text("Next")),
        //     ],
        //   )
        // ]
      );
    });
  }
}

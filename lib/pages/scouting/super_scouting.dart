import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:garagescouter/utils/may_pop_scope.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';
import 'package:garagescouter/validators/custom_integer_validators.dart';
import 'package:garagescouter/validators/custom_text_validators.dart';

class SuperScoutingPage extends StatefulWidget {
  const SuperScoutingPage({super.key, this.uuid = ""});
  final String uuid;

  @override
  State<SuperScoutingPage> createState() => _SuperScoutingPageState();
}

class _SuperScoutingPageState extends State<SuperScoutingPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  final int _durationMilliseconds = 300;

  final int _maxLines = 5;
  final int _maxLength = 1024;

  // We can't rely on _controller.page because the page is not fully updated
  // until _after_ the page has transitioned. Because of that, we need an
  // internally managed "page state" to know when we need to submit the form.
  int _currentPage = 0;

  late IsarModel _isarModel;
  late Map<String, dynamic> _initialValue;

  /// Handles form submission
  Future<void> _submitForm() async {
    bool isValid = _formKey.currentState!.saveAndValidate();

    if (!isValid) {
      errorMessageSnackbar(context,
          "Form is missing inputs. Check Initial page and verify inputs.");
      _resetPage();
      return;
    }

    // Help clean up the input by removing spaces on both ends of the string
    final Map<String, dynamic> trimmedInputs =
        _formKey.currentState!.value.map((key, value) {
      return (value is String)
          ? MapEntry(key, value.trim())
          : MapEntry(key, value);
    });

    _formKey.currentState?.patchValue(trimmedInputs);
    _formKey.currentState?.save();

    final Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    final String timestamp = DateTime.now().toString();
    state['timestamp'] = timestamp;

    final String teamNumber = state["team.number"].toString();

    SuperScoutingEntry entry = await _isarModel.getSuperDataByUUID(widget.uuid);

    bool wasDraft = entry.isDraft;

    entry
      ..isDraft = false
      ..teamNumber = int.tryParse(teamNumber) ?? 0
      ..b64String = encodeJsonToB64(state, urlSafe: true);

    await _isarModel.putScoutingData(entry).then((value) {
      _clearForm();
      successMessageSnackbar(context, "Saved Super Scouting Data");

      if (wasDraft) {
        context.pop();
      }
    }).catchError((error) {
      errorMessageSnackbar(context, error);
    });

    // try {
    //   File finalFile = await file.writeAsString(convertMapStateToString(state));

    //   saveFileToDevice(finalFile).then((file) {
    //     saveFileSnackbar(context, file);
    //   }).catchError((error) {
    //     errorMessageSnackbar(context, error);
    //   });
    // } on Exception catch (_, exception) {
    //   if (mounted) {
    //     errorMessageSnackbar(context, exception);
    //   }
    // }
  }

  Future<void> _clearForm() async {
    _formKey.currentState?.save();

    Map<String, dynamic> patchedValues = {};
    setState(() {
      _formKey.currentState!.fields.forEach((key, field) {
        field.didChange(null);
      });
      _formKey.currentState?.save();
      _formKey.currentState?.reset();

      _formKey.currentState?.patchValue(patchedValues);
      _formKey.currentState?.save();
      // _resetPage();
    });
  }

  void _resetPage() {
    setState(() {
      _currentPage = _controller.initialPage;
      _controller.animateToPage(_currentPage,
          duration: Duration(milliseconds: _durationMilliseconds),
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
  // void _onPageChanged(int pageNumber,
  //     {PageDirection direction = PageDirection.none}) {
  //   setState(() {
  //     _currentPage = pageNumber;
  //     if (direction != PageDirection.none &&
  //         (pageNumber + direction.value) >= 0) {
  //       _currentPage = pageNumber + direction.value;
  //       _controller.animateToPage(_currentPage,
  //           duration: Duration(milliseconds: durationMilliseconds),
  //           curve: Curves.ease);
  //     }
  //   });
  // }

  /// We safely save the state of the form when the user pops the Widget from
  /// the Widget Tree. Assuming that we're using imperative routing, this should
  /// pop from the widget tree.
  ///
  /// The only form validation we do is check if the `team.number` form field
  /// is not null, and if it is not null, save the entry as a draft.
  Future<bool> _onWillPop() async {
    _formKey.currentState?.save();

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    if (state.isEmpty) {
      return true;
    }

    int? teamNumber = int.tryParse(state['team.number'] ?? "");

    if (state.isEmpty || teamNumber == null) {
      return true;
    }

    SuperScoutingEntry entry = await _isarModel.getSuperDataByUUID(widget.uuid);

    String currentb64String = encodeJsonToB64(state, urlSafe: true);

    if (currentb64String == entry.b64String) {
      return true;
    }

    if (!mounted) return false;

    bool keepDraft =
        await canSaveDraft(context, exists: entry.isDraft) ?? false;

    entry
      ..teamNumber = teamNumber
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = true;

    if (keepDraft) {
      _isarModel.putScoutingData(entry).then((value) {
        _clearForm();
        successMessageSnackbar(context, "Saved Super Scouting Entry");
      }).catchError((error) {
        errorMessageSnackbar(context, error);
      });
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _isarModel = context.read<IsarModel>();

    SuperScoutingEntry? entry = _isarModel.getSuperDataByUUIDSync(widget.uuid);

    _initialValue = decodeJsonFromB64(entry.b64String);
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
      appBar: AppBar(
        title: const Text("Super Scouting"),
        centerTitle: true,
      ),
      body: MayPopScope(
        onWillPop: _onWillPop,
        child: FormBuilder(
            initialValue: _initialValue,
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: "team.number",
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
                        name: "match.number",
                        decoration: const InputDecoration(
                            labelText: "Match Number (Optional)",
                            prefixIcon: Icon(Icons.numbers)),
                        textInputAction: TextInputAction.done,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.integer(),
                          CustomTextValidators.doesNotHaveCommas(),
                          CustomIntegerValidators.notNegative()
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      FormBuilderTextField(
                        name: "notes",
                        decoration: const InputDecoration(
                          labelText: "Notes",
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
                          onPressed: _submitForm, child: const Text("Submit")),
                    ],
                  ),
                )
              ],
            )),
      ),
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
  }
}

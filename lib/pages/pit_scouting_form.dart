import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/components/forms/conditional_hidden_input.dart';
import 'package:robotz_garage_scouting/components/forms/conditional_hidden_field.dart';
import 'package:robotz_garage_scouting/components/forms/yes_or_no_field.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/utils/extensions/map_extensions.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';
import 'package:robotz_garage_scouting/validators/custom_integer_validators.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/validators/custom_text_validators.dart';

class PitScoutingPage extends StatefulWidget {
  const PitScoutingPage({super.key, this.uuid = ""});
  final String uuid;

  @override
  State<PitScoutingPage> createState() => _PitScoutingPageState();
}

class _PitScoutingPageState extends State<PitScoutingPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  late IsarModel _isarModel;
  late Map<String, dynamic> _initialValue;

  /// Handles form submission
  Future<void> _submitForm() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    bool isValid = _formKey.currentState!.saveAndValidate();

    if (!isValid) {
      errorMessageSnackbar(context,
          "One or more fields are invalid. Review your inputs and try submitting again.");
      return;
    }

    // check if the "drive_train" is not set to other and if it isn't,
    // delete the contents of the "other_drive_train" column.
    if (_formKey.currentState?.value["drive_train"] != "Other") {
      _formKey.currentState?.patchValue({"other_drive_train": ""});
      _formKey.currentState?.save();
    }

    // We can't rely on FlutterFormBuilder to assign a true default value to
    // their fields, so we go back and verify that the ones we know cause
    // issues are forced to be reset to a default value before we try to
    // write the data to CSV.
    _formKey.currentState?.fields.forEach((key, value) {
      if (value.widget is FormBuilderTextField && value.value == null) {
        _formKey.currentState?.patchValue({key: ""});
      }

      if (value.widget is FormBuilderCheckboxGroup) {
        if (value.value == null) {
          _formKey.currentState?.patchValue({key: <String>[]});
        }
        _formKey.currentState?.patchValue({
          key: (value.value as List<dynamic>)
              .sorted((dynamic left, dynamic right) {
            return left.toString().compareTo(right.toString());
          })
        });
      }

      if (value.widget is YesOrNoFieldType && value.value == null) {
        _formKey.currentState?.patchValue({key: YesOrNoEnumType.no.label});
      }
    });

    _formKey.currentState?.save();

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    state['timestamp'] = DateTime.now().toString();

    final String teamNumber = state["team_number"].toString();

    PitScoutingEntry entry = await _isarModel.getPitDataByUUID(widget.uuid);

    bool wasDraft = entry.isDraft ?? false;

    entry
      ..teamNumber = int.tryParse(teamNumber)
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = false;

    _isarModel.putScoutingData(entry).then((value) {
      _clearForm();
      successMessageSnackbar(context, "Saved data to Isar, Index $value");

      if (wasDraft) {
        context.pop();
      }
    }).catchError((error) {
      errorMessageSnackbar(context, error);
    });
  }

  /// Helper to update Form State for other form elements that are dependent on state
  void _saveFormState(value) {
    setState(() {
      _formKey.currentState?.save();
    });
  }

  /// Determines if we can show the "Other Drive Train Field"
  /// We want to show it under one of two situations:
  /// 1. The user selected "Other" for "drive_train"
  /// 2. It is the first render and the user had selected
  ///    "Other" previously for "drive_train"
  bool _canShowFieldFromMatch({required String key, required String match}) {
    final String current = (_formKey.currentState?.value[key] ?? "").toString();

    // On the first load, the currentState will be empty, so we need
    // to check if it's empty, but after that we can assume we check
    // the current field value.
    if (current.isNotEmpty && current != match) {
      return false;
    }

    // Otherwise just find if either contains the match.
    return [current, _initialValue[key].toString()].contains(match);
  }

  /// This is a fairly hacky workaround to work around form fields that aren't
  /// immediately shown on the screen. For Pit Scouting, the "Other Drive Train"
  /// field. We wait for the file system to complete and then reset/save the form.
  Future<void> _clearForm() async {
    _formKey.currentState?.save();

    // setState(() {
    //   _formKey.currentState!.fields.forEach((key, field) {
    //     field.didChange(null);
    //   });
    //   _formKey.currentState?.save();

    //   context.read<RetainInfoModel>().resetPitScouting();
    // });
  }

  /// We safely save the state of the form when the user pops the Widget from
  /// the Widget Tree. Assuming that we're using imperative routing, this should
  /// pop from the widget tree.
  ///
  /// The only form validation we do is check if the `team_number` form field
  /// is not null, and if it is not null, save the entry as a draft.
  Future<bool> _onWillPop() async {
    _formKey.currentState?.save();

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    if (state.isEveryValueEmpty() || state.valueForKeyIsNull('team_number')) {
      return true;
    }

    PitScoutingEntry entry = await _isarModel.getPitDataByUUID(widget.uuid);

    String currentb64String = encodeJsonToB64(state, urlSafe: true);

    if (currentb64String == entry.b64String) {
      return true;
    }

    bool keepDraft = await canSaveDraft(context, exists: entry.isDraft);

    entry
      ..teamNumber = int.tryParse(state['team_number'])
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

  @override
  void initState() {
    super.initState();
    _isarModel = context.read<IsarModel>();

    PitScoutingEntry entry = _isarModel.getPitDataByUUIDSync(widget.uuid);

    _initialValue = decodeJsonFromB64(entry.b64String ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pit Scouting",
          textAlign: TextAlign.center,
        ),
      ),
      body: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: WillPopScope(
              onWillPop: _onWillPop,
              child: Column(
                children: [
                  FormBuilder(
                    initialValue: _initialValue,
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Divider(),
                        const Text("General Questions"),
                        const Divider(),
                        FormBuilderTextField(
                          name: "team_name",
                          decoration: const InputDecoration(
                              labelText: "What is the Team Name?",
                              prefixIcon: Icon(Icons.abc)),
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            CustomTextValidators.doesNotHaveCommas(),
                          ]),
                        ),
                        FormBuilderTextField(
                          name: "team_number",
                          decoration: const InputDecoration(
                              labelText: "What is the Team Number?",
                              prefixIcon: Icon(Icons.numbers)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.integer(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderChoiceChip(
                            name: "drive_train",
                            decoration: const InputDecoration(
                                labelText:
                                    "What kind of Drive Train do they have?",
                                prefixIcon: Icon(Icons.drive_eta)),
                            onChanged: _saveFormState,
                            validator: FormBuilderValidators.required(),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            options: [
                              "Tank Drive",
                              "West Coast",
                              "Mecanum",
                              "Swerve Drive",
                              "Other"
                            ]
                                .map((option) => FormBuilderChipOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        ConditionalHiddenTextField(
                          name: "other_drive_train",
                          showWhen: _canShowFieldFromMatch(
                              key: "drive_train", match: "Other"),
                        ),
                        YesOrNoFieldWidget(
                          name: "has_arm",
                          label: "Do they have an arm?",
                          validators: FormBuilderValidators.required(),
                          onChanged: _saveFormState,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        YesOrNoFieldWidget(
                          name: "has_intake",
                          label: "Do they have an intake system?",
                          validators: FormBuilderValidators.required(),
                          onChanged: _saveFormState,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        ConditionalHiddenField(
                            showWhen: _canShowFieldFromMatch(
                                key: 'has_intake',
                                match: YesOrNoEnumType.yes.toString()),
                            child: FormBuilderCheckboxGroup<dynamic>(
                              name: "pickup_from_intake",
                              decoration: const InputDecoration(
                                  labelText:
                                      "Where does the robot intake from?"),
                              options: ["Floor", "Substation", "Chute"]
                                  .map((e) => FormBuilderFieldOption(
                                      value: e.toString()))
                                  .toList(),
                            )),
                        FormBuilderCheckboxGroup<dynamic>(
                          name: "scorable_pieces",
                          decoration: const InputDecoration(
                              labelText:
                                  "What game pieces can the robot score?"),
                          options: ["Cones", "Cubes"]
                              .map((e) =>
                                  FormBuilderFieldOption(value: e.toString()))
                              .toList(),
                        ),
                        const Divider(),
                        const Text("Autonomous Questions"),
                        const Divider(),
                        YesOrNoFieldWidget(
                          name: "has_autonomous",
                          label: "Do they have autonomous?",
                          validators: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: _saveFormState,
                        ),
                        ConditionalHiddenField(
                          showWhen: _canShowFieldFromMatch(
                              key: "has_autonomous",
                              match: YesOrNoEnumType.yes.toString()),
                          child: YesOrNoFieldWidget(
                            name: "can_score_autonomous",
                            label: "Are they able to score in autonomous?",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        ConditionalHiddenField(
                          showWhen: _canShowFieldFromMatch(
                              key: "can_score_autonomous",
                              match: YesOrNoEnumType.yes.toString()),
                          child: FormBuilderCheckboxGroup<dynamic>(
                            name: "auto_score_cones",
                            decoration: const InputDecoration(
                                icon: Icon(Icons.score),
                                labelText:
                                    "What Cones can they score in Autonomous?"),
                            options: ["Low", "Mid", "High"]
                                .map((e) =>
                                    FormBuilderFieldOption(value: e.toString()))
                                .toList(),
                          ),
                        ),
                        ConditionalHiddenField(
                          showWhen: _canShowFieldFromMatch(
                              key: "can_score_autonomous",
                              match: YesOrNoEnumType.yes.toString()),
                          child: FormBuilderCheckboxGroup<dynamic>(
                            name: "auto_score_cubes",
                            decoration: const InputDecoration(
                                icon: Icon(Icons.score),
                                labelText:
                                    "What Cubes can they score in Autonomous?"),
                            options: ["Low", "Mid", "High"]
                                .map((e) =>
                                    FormBuilderFieldOption(value: e.toString()))
                                .toList(),
                          ),
                        ),
                        ConditionalHiddenField(
                          showWhen: _canShowFieldFromMatch(
                              key: "has_autonomous",
                              match: YesOrNoEnumType.yes.toString()),
                          child: YesOrNoFieldWidget(
                            name: "can_charge_autonomous",
                            label:
                                "Are they able to use the charge station in autonomous?",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validators: _canShowFieldFromMatch(
                                    key: "has_autonomous",
                                    match: YesOrNoEnumType.yes.toString())
                                ? FormBuilderValidators.required()
                                : null,
                          ),
                        ),
                        ConditionalHiddenField(
                            showWhen: _canShowFieldFromMatch(
                                key: "has_autonomous",
                                match: YesOrNoEnumType.yes.toString()),
                            child: FormBuilderCheckboxGroup<dynamic>(
                              name: "auto_starting_positions",
                              decoration: const InputDecoration(
                                  labelText:
                                      "Where can they start in Autonomous?"),
                              options: ["Center", "Bump", "Lane"]
                                  .map((e) => FormBuilderFieldOption(
                                      value: e.toString()))
                                  .toList(),
                            )),
                        ConditionalHiddenField(
                          showWhen: _canShowFieldFromMatch(
                              key: "has_autonomous",
                              match: YesOrNoEnumType.yes.toString()),
                          child: FormBuilderTextField(
                            name: "auto_notes",
                            decoration: const InputDecoration(
                                labelText: "Autonmous Notes (if needed)?",
                                prefixIcon: Icon(Icons.note)),
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: FormBuilderValidators.compose([
                              CustomTextValidators.doesNotHaveCommas(),
                            ]),
                          ),
                        ),
                        const Divider(),
                        const Text("Teleop Questions"),
                        const Divider(),
                        FormBuilderCheckboxGroup<dynamic>(
                          name: "teleop_score_cones",
                          decoration: const InputDecoration(
                              icon: Icon(Icons.score),
                              labelText: "Can they score Cones in Teleop?"),
                          options: ["Low", "Mid", "High"]
                              .map((e) =>
                                  FormBuilderFieldOption(value: e.toString()))
                              .toList(),
                        ),
                        FormBuilderCheckboxGroup<dynamic>(
                          name: "teleop_score_cubes",
                          decoration: const InputDecoration(
                              icon: Icon(Icons.score),
                              labelText: "Can they score Cubes in Teleop?"),
                          options: ["Low", "Mid", "High"]
                              .map((e) =>
                                  FormBuilderFieldOption(value: e.toString()))
                              .toList(),
                        ),
                        YesOrNoFieldWidget(
                          name: "can_defend",
                          label: "Can the robot defend?",
                          validators: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        YesOrNoFieldWidget(
                          name: "can_shuttle",
                          label:
                              "Can their robot shuttle pieces for other robots?",
                          validators: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        FormBuilderTextField(
                          name: "teleop_notes",
                          decoration: const InputDecoration(
                              labelText: "Teleop Notes (if needed)?",
                              prefixIcon: Icon(Icons.note)),
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            CustomTextValidators.doesNotHaveCommas(),
                          ]),
                        ),
                        const Divider(),
                        const Text("Endgame Questions"),
                        const Divider(),
                        YesOrNoFieldWidget(
                          icon: Icons.balance,
                          name: "endgame_balance",
                          label:
                              "Can they balance on the charging station in end game?",
                          validators: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const Divider(),
                        const Text("Other Questions"),
                        const Divider(),
                        FormBuilderTextField(
                          name: "final_notes",
                          decoration: const InputDecoration(
                              labelText: "Any other Notes (if needed)?",
                              prefixIcon: Icon(Icons.note)),
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            CustomTextValidators.doesNotHaveCommas(),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: _submitForm, child: const Text("Submit"))
                      ],
                    ),
                  )
                ],
              )),
        )
      ]),
    );
  }
}

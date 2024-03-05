import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:garagescouter/utils/may_pop_scope.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:garagescouter/utils/extensions/map_extensions.dart';
import 'package:garagescouter/utils/notification_helpers.dart';
import 'package:garagescouter/validators/custom_integer_validators.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/validators/custom_text_validators.dart';

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

    // We can't rely on FlutterFormBuilder to assign a true default value to
    // their fields, so we go back and verify that the ones we know cause
    // issues are forced to be reset to a default value before we try to
    // write the data to CSV.
    _formKey.currentState?.fields.forEach((key, value) {
      if (value.widget is FormBuilderTextField && value.value == null) {
        _formKey.currentState?.patchValue({key: ""});
      }

      // if (value.widget is FormBuilderCheckboxGroup) {
      //   if (value.value == null) {
      //     _formKey.currentState?.patchValue({key: <String>[]});
      //   }
      //   _formKey.currentState?.patchValue({
      //     key: (value.value as List<dynamic>)
      //         .sorted((dynamic left, dynamic right) {
      //       return left.toString().compareTo(right.toString());
      //     })
      //   });
      // }

      // if (value.widget is YesOrNoFieldType && value.value == null) {
      //   _formKey.currentState?.patchValue({key: YesOrNoEnumType.no.label});
      // }
    });

    _formKey.currentState?.save();

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    state['timestamp'] = DateTime.now().toString();

    final String teamNumber = state["team.number"].toString();

    PitScoutingEntry entry = await _isarModel.getPitDataByUUID(widget.uuid);

    bool wasDraft = entry.isDraft;

    entry
      ..teamNumber = int.tryParse(teamNumber) ?? 0
      ..b64String = encodeJsonToB64(state, urlSafe: true)
      ..isDraft = false;

    _isarModel.putScoutingData(entry).then((value) {
      _clearForm();
      successMessageSnackbar(context, "Saved Pit Scouting Data");

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

    setState(() {
      _formKey.currentState!.fields.forEach((key, field) {
        field.didChange(null);
      });
      _formKey.currentState?.save();
    });
  }

  /// We safely save the state of the form when the user pops the Widget from
  /// the Widget Tree. Assuming that we're using imperative routing, this should
  /// pop from the widget tree.
  ///
  /// The only form validation we do is check if the `team.number` form field
  /// is not null, and if it is not null, save the entry as a draft.
  Future<bool> _onWillPop() async {
    _formKey.currentState?.save();

    Map<String, dynamic> state = Map.from(_formKey.currentState!.value);

    if (state.isEveryValueEmpty() || state.valueForKeyIsNull('team.number')) {
      return true;
    }

    PitScoutingEntry entry = await _isarModel.getPitDataByUUID(widget.uuid);

    String currentb64String = encodeJsonToB64(state, urlSafe: true);

    if (currentb64String == entry.b64String) {
      return true;
    }

    if (!mounted) return false;

    bool keepDraft =
        await canSaveDraft(context, exists: entry.isDraft) ?? false;

    entry
      ..teamNumber = int.tryParse(state['team.number']) ?? 0
      ..b64String = currentb64String
      ..isDraft = true;

    if (keepDraft) {
      _isarModel.putScoutingData(entry).then((value) {
        _clearForm();
        successMessageSnackbar(context, "Saved Pit Scouting Entry");
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

    _initialValue = decodeJsonFromB64(entry.b64String);
  }

  String? motorCheckboxValidator(List<String>? options) =>
      (options ?? []).isEmpty ? "At least one motor type is required" : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pit Scouting"),
        centerTitle: true,
      ),
      body: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: MayPopScope(
              onWillPop: _onWillPop,
              child: Column(
                children: [
                  FormBuilder(
                    initialValue: _initialValue,
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: const Text("General Questions"),
                          tileColor: Theme.of(context).highlightColor,
                        ),
                        const Divider(),
                        FormBuilderTextField(
                          name: "team.number",
                          decoration: const InputDecoration(
                              labelText: "Team Number",
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
                        ListTile(
                          title: const Text("Robot Characteristics"),
                          tileColor: Theme.of(context).focusColor,
                        ),
                        const Divider(),
                        FormBuilderTextField(
                          name: "robot.weight",
                          decoration: const InputDecoration(
                              labelText: "Robot Weight? (Pounds)",
                              prefixIcon: Icon(Icons.line_weight)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: "robot.travel.height",
                          decoration: const InputDecoration(
                              labelText:
                                  "Robot Height when moving across the field? (Inches)",
                              prefixIcon: Icon(Icons.height)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: "robot.max.height",
                          decoration: const InputDecoration(
                              labelText: "Robot Maximum Height? (Inches)",
                              prefixIcon: Icon(Icons.height)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: "robot.dimensions.length",
                          decoration: const InputDecoration(
                              labelText: "Robot Length? (Inches)",
                              prefixIcon: Icon(Icons.width_normal)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: "robot.dimensions.width",
                          decoration: const InputDecoration(
                              labelText: "Robot Width? (Inches)",
                              prefixIcon: Icon(Icons.width_normal)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            CustomTextValidators.doesNotHaveCommas(),
                            CustomIntegerValidators.notNegative()
                          ]),
                        ),
                        FormBuilderDropdown(
                            name: "robot.drive.train",
                            decoration: const InputDecoration(
                                labelText:
                                    "What kind of Drive Train do they have?",
                                prefixIcon: Icon(Icons.drive_eta)),
                            onChanged: _saveFormState,
                            validator: FormBuilderValidators.required(),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            items: [
                              "Tank",
                              "West Coast",
                              "Mecanum",
                              "Swerve",
                              "Other"
                            ]
                                .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        const ListTile(
                            leading: Icon(Icons.motorcycle),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "What kind of Drive/Rotation motors? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.drive.motors",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: motorCheckboxValidator,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            options: [
                              "REV NEO Brushless",
                              "REV NEO 550",
                              "REV Vortex",
                              "Falcon 500",
                              "Kraken X60",
                              "Brushed (CIM, Mini CIM, 775, etc)",
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        FormBuilderDropdown(
                            name: "robot.drive.module",
                            decoration: const InputDecoration(
                                labelText:
                                    "If Swerve, which modules do they use?",
                                prefixIcon: Icon(Icons.drive_eta)),
                            onChanged: _saveFormState,
                            items: ["NA", "REV Swerve MAX", "SDS", "Other"]
                                .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        FormBuilderTextField(
                          name: "robot.battery",
                          decoration: const InputDecoration(
                              labelText: "Battery Brand?",
                              prefixIcon: Icon(Icons.battery_unknown)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            CustomTextValidators.doesNotHaveCommas(),
                          ]),
                        ),
                        ListTile(
                          title: const Text("Physical Mechanisms"),
                          tileColor: Theme.of(context).highlightColor,
                        ),
                        const Divider(),
                        const ListTile(
                            leading: Icon(Icons.arrow_upward),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "How does the robot intake? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.intake.method",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            options: [
                              "Over-the-Bumper",
                              "Under-the-Bumper",
                              "Human Player Feed",
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        FormBuilderTextField(
                          name: "robot.climbing.mechanism",
                          decoration: const InputDecoration(
                              labelText:
                                  "What mechanisms do they use for climbing?",
                              prefixIcon: Icon(Icons.elevator)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            CustomTextValidators.doesNotHaveCommas(),
                          ]),
                        ),
                        FormBuilderDropdown(
                            name: "robot.under.stage",
                            decoration: const InputDecoration(
                                labelText: "Can the robot go under the stage?",
                                prefixIcon: Icon(Icons.local_car_wash)),
                            onChanged: _saveFormState,
                            items: ["Yes", "No"]
                                .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        const ListTile(
                            leading: Icon(Icons.motorcycle),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "What motors do their mechanisms use? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.mechanism.motors",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            validator: motorCheckboxValidator,
                            options: [
                              "REV NEO Brushless",
                              "REV NEO 550",
                              "REV Vortex",
                              "Falcon 500",
                              "Kraken X60",
                              "Brushed (CIM, Mini CIM, 775, etc)",
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        ListTile(
                          title: const Text("Software Mechanisms"),
                          tileColor: Theme.of(context).highlightColor,
                        ),
                        const Divider(),
                        const ListTile(
                            leading: Icon(Icons.visibility),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "Which Software(s) are they using for Vision? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.vision.software",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            options: [
                              "PhotonVision",
                              "LimeLight",
                              "North Star",
                              "Other"
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        const ListTile(
                            leading: Icon(Icons.camera_alt),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "Which Camera(s) are they using for Vision? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.vision.cameras",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            options: [
                              "LimeLight 2",
                              "LimeLight 3",
                              "Arducam OV9281 (Black and White)",
                              "Arducam OV9782 (Color)",
                              "Raspberry Pi CSI",
                              "Other"
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        const ListTile(
                            leading: Icon(Icons.map),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                                "Which Softwares(s) are they using for Autonomous? Check all that apply.")),
                        FormBuilderCheckboxGroup(
                            name: "robot.auto.software",
                            onChanged: _saveFormState,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            wrapDirection: Axis.vertical,
                            wrapAlignment: WrapAlignment.spaceEvenly,
                            orientation: OptionsOrientation.vertical,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0)),
                            options: [
                              "PathPlanner",
                              "PathWeaver",
                              "Timed Code loop",
                            ]
                                .map((option) => FormBuilderFieldOption(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    )))
                                .toList(growable: false)),
                        ListTile(
                          title: const Text("Other notes"),
                          tileColor: Theme.of(context).highlightColor,
                        ),
                        const Divider(),
                        FormBuilderTextField(
                          name: "other.notes",
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

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key});

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingPageState();
}

class _MatchScoutingPageState extends State<MatchScoutingPage> {
  final String title = "Match Scouting Form";
  final _formKey = GlobalKey<FormBuilderState>();

  submitForm() {
    _formKey.currentState!.save();
    print("current state :: ${_formKey.currentState!.value}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        title: Center(child: Text(title)),
      ),
      SliverToBoxAdapter(
          child: FormBuilder(
        key: _formKey,
        child: Column(children: [
          const Text("Cubes Collected"),
          IncrementFormBuilderField(name: "cubes_collected"),
          const Text("Cones Collected"),
          IncrementFormBuilderField(name: "cones_collected"),
          IconButton(
              onPressed: submitForm, icon: const Icon(Icons.send_rounded))
        ]),
      ))
    ]));
  }
}

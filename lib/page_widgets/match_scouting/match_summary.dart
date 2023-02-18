import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Scrollable screen that represents the "end of round/match" survey that scouters can submit
class MatchSummaryScreen extends StatefulWidget {
  const MatchSummaryScreen({super.key});

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Center(
      child: Column(children: [
        const Text("SUMMARY"),
        FormBuilderTextField(
          name: "summary_notes",
          initialValue: "",
          maxLength: 256,
          maxLines: 5,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => value != null && value.contains(RegExp(","))
              ? "Cannot contain commas."
              : null,
        )
      ]),
    ));
  }
}

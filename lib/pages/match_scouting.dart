import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/components/forms/increment_field.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_auto.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_endgame.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_initial.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_summary.dart';
import 'package:robotz_garage_scouting/page_widgets/match_scouting/match_teleop.dart';

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

  final List<Widget> pages = const [
    MatchInitialScreen(),
    MatchAutonomousScreen(),
    MatchTeleopScreen(),
    MatchEndgameScreen(),
    MatchSummaryScreen()
  ];

  void _submitForm() {
    _formKey.currentState!.save();
    print("current state :: ${_formKey.currentState!.value}");
  }

  ///
  // bool _isOnLastPage() => (_controller.page ?? 0) >= (pages.length - 1);

  /// Handles Previous Page functionality for desktop/accessibility
  void _prevPage() {
    setState(() {
      if (_controller.page! <= _controller.initialPage) {
        print("already on first page");
        return;
      }

      _controller.previousPage(
          duration: Duration(milliseconds: durationMilliseconds),
          curve: Curves.ease);
    });
  }

  /// Handles Next Page functionality for desktop/accessibility
  void _nextPage() {
    setState(() {
      // if (_controller.page! >= pages.length - 1) {
      //   print("already on last page");
      //   // return;
      // }

      _controller.nextPage(
          duration: Duration(milliseconds: durationMilliseconds),
          curve: Curves.ease);
    });
  }

  void _pageListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      print("scroll forward");
    } else {
      print("scroll backwards");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_pageListener);
  }

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
            child: PageView(
              controller: _controller,
              children: pages,
            )),
        persistentFooterButtons: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: _prevPage, child: Text("Previous")),
              // (_controller.page! + 2) > (pages.length)
              //     ? ElevatedButton(
              //         onPressed: _submitForm, child: Text("Submit"))
              //     :
              ElevatedButton(onPressed: _nextPage, child: Text("Next")),
            ],
          )
        ]
        //   body: CustomScrollView(slivers: <Widget>[
        // SliverAppBar(
        //   pinned: true,
        //   title: Center(child: Text(title)),
        // ),
        // SliverToBoxAdapter(
        //     child: FormBuilder(
        //   key: _formKey,
        //   child:
        // child: Column(children: [
        //   const Text("Cubes Collected"),
        //   IncrementFormBuilderField(name: "cubes_collected"),
        //   const Text("Cones Collected"),
        //   IncrementFormBuilderField(name: "cones_collected"),
        //   IconButton(
        //       onPressed: submitForm, icon: const Icon(Icons.send_rounded))
        // ]),
        //   ))
        // ])
        );
  }
}

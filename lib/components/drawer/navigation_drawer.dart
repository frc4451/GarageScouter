import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';

class CustomDrawerComponent extends StatefulWidget {
  const CustomDrawerComponent({super.key});

  @override
  State<CustomDrawerComponent> createState() => _CustomDrawerComponentState();
}

class _CustomDrawerComponentState extends State<CustomDrawerComponent> {
  void _navigateToSecondPage() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const MyHomePage(
              title: 'Home page',
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text("This is the second page"),
            // leading: const IconButton(
            //   icon: Icons.arrow_back,
            //   onPressed: (() {
            //    Navigator.pop(context);
            //   },
            // ),
            actions: <Widget>[
              IconButton(
                  onPressed: _navigateToSecondPage,
                  icon: const Icon(Icons.all_inbox))
            ]),
        body: Center(
          child: Column(
            children: const [Text("Some second page")],
          ),
        ));
  }
}

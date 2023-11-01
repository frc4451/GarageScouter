import 'package:flutter/material.dart';

class EventSelectionPage extends StatefulWidget {
  const EventSelectionPage({super.key});

  @override
  State<EventSelectionPage> createState() => _EventSelectionPageState();
}

class _EventSelectionPageState extends State<EventSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Event",
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add))
        ],
      ),
      body: Column(
          children: ListTile.divideTiles(context: context, tiles: [
        const ListTile(
          title: Text("Event 1"),
        ),
        const ListTile(
          title: Text("Event 2"),
        ),
        const ListTile(
          title: Text("Event 3"),
        ),
      ]).toList()),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';

class EventSelectionPage extends StatefulWidget {
  const EventSelectionPage({super.key});

  @override
  State<EventSelectionPage> createState() => _EventSelectionPageState();
}

class _EventSelectionPageState extends State<EventSelectionPage> {
  late IsarModel _isarModel;

  List<Event> _events = [];
  late StreamSubscription<List<Event>> _eventsSubscription;

  @override
  void initState() {
    super.initState();

    _isarModel = context.read<IsarModel>();
    _updateEvents();

    Stream<List<Event>> eventsStream = _isarModel.getEvents();
    _eventsSubscription = eventsStream.listen((events) {
      setState(() {
        _events = events;
      });
    });
  }

  @override
  void deactivate() {
    _eventsSubscription.cancel();
    super.deactivate();
  }

  void _updateEvents() {
    _isarModel.getAllEvents().then((queriedEvents) {
      setState(() {
        _events = queriedEvents;
      });
    });
  }

  void _addEvent() async {
    TextEditingController textController = TextEditingController();

    String? eventName = await showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add Event"),
              content: TextField(
                controller: textController,
                decoration: InputDecoration(hintText: "Name of the event..."),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        child: const Text("Cancel")),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(textController.text);
                        },
                        child: const Text("Confirm")),
                  ],
                )
              ],
            ));
    if (eventName != null) {
      await _isarModel.addEventByName(eventName);
      _updateEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Select Event",
            textAlign: TextAlign.center,
          ),
          actions: [
            IconButton(onPressed: _addEvent, icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: ListTile.divideTiles(
              context: context,
              tiles: _events.map((e) => ListTile(
                    title: Text(e.name!),
                    onTap: () {
                      setState(() {
                        _isarModel.setEvent(e.name!);
                      });
                    },
                    leading: Icon(_isarModel.selectedEvent == e.name
                        ? Icons.check_circle
                        : Icons.circle_outlined),
                  ))).toList(),
        ));
  }
}

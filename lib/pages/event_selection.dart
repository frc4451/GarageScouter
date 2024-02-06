import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garagescouter/utils/notification_helpers.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/models/isar_model.dart';

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
    TextEditingController nameTextController = TextEditingController();
    TextEditingController descriptionTextController = TextEditingController();

    Event? newEvent = await showDialog<Event?>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Add Event",
                textAlign: TextAlign.center,
              ),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameTextController,
                  decoration:
                      const InputDecoration(hintText: "Name of the event..."),
                ),
                TextField(
                  controller: descriptionTextController,
                  decoration: const InputDecoration(hintText: "Description..."),
                )
              ]),
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
                          Navigator.of(context).pop(Event()
                            ..name = nameTextController.text
                            ..description = descriptionTextController.text);
                        },
                        child: const Text("Confirm")),
                  ],
                )
              ],
            ));

    if (newEvent != null) {
      await _isarModel.putEvent(newEvent);
      _updateEvents();
    }
  }

  void _editEvent(Event event) async {
    TextEditingController nameTextController =
        TextEditingController(text: event.name);
    TextEditingController descriptionTextController =
        TextEditingController(text: event.description);

    Event? newEvent = await showDialog<Event?>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Update Event",
                textAlign: TextAlign.center,
              ),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameTextController,
                  decoration:
                      const InputDecoration(hintText: "Name of the event..."),
                ),
                TextField(
                  controller: descriptionTextController,
                  decoration: const InputDecoration(hintText: "Description..."),
                )
              ]),
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
                          Navigator.of(context).pop(event
                            ..name = nameTextController.text
                            ..description = descriptionTextController.text);
                        },
                        child: const Text("Confirm")),
                  ],
                )
              ],
            ));
    if (newEvent != null) {
      await _isarModel.updateEvent(newEvent);
      _updateEvents();
    }
  }

  void _deleteEvent(Event event) async {
    bool? canDelete = await showDialog<bool?>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Event?"),
              content: const Text(
                  "Are you sure you want to delete this Event?\nThis will delete all data for the Event."),
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
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Confirm")),
                  ],
                )
              ],
            ));

    if (canDelete ?? false) {
      if (_events.length <= 1) {
        if (!mounted) return;

        errorMessageSnackbar(
            context, "You can't delete events if there is only one event!");
        return;
      }

      await _isarModel.deleteEvent(event);
      _updateEvents();

      if (_isarModel.selectedEvent.isEmpty) {
        _isarModel.setEvent(_events.first.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select Event"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: _addEvent, icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: ListTile.divideTiles(
              context: context,
              tiles: _events.map((e) => ListTile(
                    title: Text(e.name),
                    subtitle:
                        e.description != null ? Text(e.description!) : null,
                    onTap: () {
                      setState(() {
                        _isarModel.setEvent(e.name);
                      });
                    },
                    leading: Icon(_isarModel.selectedEvent == e.name
                        ? Icons.check_circle
                        : Icons.circle_outlined),
                    trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => _editEvent(e),
                                child: const Text("Edit"),
                              ),
                              PopupMenuItem(
                                onTap: () => _deleteEvent(e),
                                child: const Text("Delete"),
                              ),
                            ]),
                  ))).toList(),
        ));
  }
}

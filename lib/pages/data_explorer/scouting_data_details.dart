import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';

class ScoutingDataDetailsPage extends StatefulWidget {
  final String? hash;

  const ScoutingDataDetailsPage({super.key, this.hash});

  @override
  State<ScoutingDataDetailsPage> createState() =>
      _ScoutingDataDetailsPageState();
}

class _ScoutingDataDetailsPageState extends State<ScoutingDataDetailsPage> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();

    data = decodeJsonFromB64(widget.hash ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              "Scouting Data",
              textAlign: TextAlign.center,
            ),
            actions: [
              PopupMenuButton(
                  itemBuilder: (context) => [
                        const PopupMenuItem(child: Text("Edit")),
                      ])
            ]),
        body: ListView(
          children: [
            for (final entry in data.entries)
              Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.toString()),
                ),
              )
          ],
        ));
  }
}

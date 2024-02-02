import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:garagescouter/utils/hash_helpers.dart';

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
        body: DataTable2(
          columns: const [
            DataColumn2(label: Text("Key")),
            DataColumn2(label: Text("Value")),
          ],
          rows: data.keys
              .map((String key) => DataRow2(cells: [
                    DataCell(Text(key)),
                    DataCell(Text(data[key].toString()))
                  ]))
              .toList(),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/test.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

class DatabaseTestingPage extends StatefulWidget {
  const DatabaseTestingPage({super.key});

  @override
  State<DatabaseTestingPage> createState() => _DatabaseTestingPageState();
}

class _DatabaseTestingPageState extends State<DatabaseTestingPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  List<TestDatabaseEntry> _entries = [];

  late Isar isar;

  /// Given the `title` and `text` from the FlutterFormBuilder state, we can
  /// create a new `TestDatabaseEntry` and save it to our Isar database.
  Future<void> _createDatabaseEntry() async {
    _formKey.currentState?.save();

    final String title = _formKey.currentState?.value['title'] ?? "";
    final String text = _formKey.currentState?.value['text'] ?? "";

    if (title.isEmpty || text.isEmpty) {
      errorMessageSnackbar(context, "Title or Text field cannot be empty.");
      return;
    }

    final TestDatabaseEntry entry = TestDatabaseEntry()
      ..text = text
      ..title = title;

    await isar.writeTxn(() => isar.testDatabaseEntrys.put(entry));

    setState(() {
      _readEntries();
      _formKey.currentState?.reset();
    });
  }

  /// Given a `TestDatabaseEntry`, we have an ID associated that is used to
  /// delete the entry in-place.
  Future<void> _deleteDatabaseEntry(TestDatabaseEntry entry) async {
    await isar.writeTxn(() => isar.testDatabaseEntrys.delete(entry.id));

    setState(() {
      _readEntries();
    });
  }

  /// Grabs the current list of database entries and adds them to the list
  /// of entries.
  Future<void> _readEntries() async {
    final List<TestDatabaseEntry> entries =
        await isar.testDatabaseEntrys.filter().titleIsNotEmpty().findAll();

    setState(() {
      _entries = entries;
    });
  }

  @override
  void initState() {
    super.initState();
    isar = context.read<IsarModel>().isar;
    _readEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Database Tester for Isar",
            textAlign: TextAlign.center,
          ),
        ),
        body: FormBuilder(
          key: _formKey,
          child: Center(
              child: Column(children: [
            FormBuilderTextField(
              name: "title",
              decoration: const InputDecoration(labelText: "Title"),
            ),
            FormBuilderTextField(
              name: "text",
              decoration: const InputDecoration(labelText: "Text"),
              onSubmitted: (value) => _createDatabaseEntry(),
            ),
            ElevatedButton(
                onPressed: _createDatabaseEntry, child: const Text("Add Item")),
            if (_entries.isNotEmpty)
              Expanded(
                  child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(border: TableBorder.all(), children: [
                  const TableRow(children: [
                    TableCell(
                        child: Text(
                      "Title",
                      textAlign: TextAlign.center,
                    )),
                    TableCell(
                        child: Text(
                      "Text",
                      textAlign: TextAlign.center,
                    )),
                    TableCell(child: Text("Action"))
                  ]),
                  for (final entry in _entries)
                    TableRow(children: [
                      TableCell(
                          child: Text(
                        entry.title ?? "",
                        textAlign: TextAlign.center,
                      )),
                      TableCell(
                          child: Text(
                        entry.text ?? "",
                        textAlign: TextAlign.center,
                      )),
                      TableCell(
                          child: OutlinedButton(
                        child: const Text("Delete"),
                        onPressed: () async {
                          await _deleteDatabaseEntry(entry);
                        },
                      ))
                    ])
                ]),
              )),
            // for (final entry in _entries)
            //   Column(
            //     children: [Text(entry.title ?? ""), Text(entry.text ?? "")],
            //   )
          ])),
        ));
  }
}

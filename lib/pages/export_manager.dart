import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';

class ExportManagerPage extends StatefulWidget {
  const ExportManagerPage({super.key});

  @override
  State<ExportManagerPage> createState() => _ExportManagerPageState();
}

class _ExportManagerPageState extends State<ExportManagerPage> {
  QrImage? image;

  void _kSuccessMessage(String value) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Successfully wrote file $value",
          textAlign: TextAlign.center,
        )));
  }

  void _kFailureMessage(error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        )));
  }

  /// Opens the user prompt to
  Future<void> _generateQRCodeFromCSV() async {
    Map<String, dynamic> fileData = {};

    List<PlatformFile>? selectedFiles = (await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
            allowedExtensions: ["csv"]))
        ?.files;

    // The rest of the function requires that selected files are not null.
    if (selectedFiles == null) {
      _kFailureMessage("No files selected. User aborted action.");
      return;
    }

    await Future.forEach(selectedFiles, (PlatformFile file) async {
      DataFrame df = await fromCsv(file.path!);

      // Because we may run into issues with different header values,
      // we can just create sub-objects so we can easily guarentee
      // type safety and easily writing the files on the receiving end.
      fileData[file.name] = {
        "header": df.header.toList(),
        "rows": df.rows.toList().asMap().map(
              (key, value) => MapEntry(key.toString(), value.toList()),
            )
      };
    });

    setState(() {
      image = QrImage(
        data: encodeJsonForQRCode(fileData),
        version: QrVersions.auto,
        backgroundColor: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Export Manager",
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (image == null)
          const Text(
            "This page is designed to help users share data between devices.\n"
            "You can select the button below to select the files you would like "
            "to share with mentors.\n",
            textAlign: TextAlign.center,
          )
        else
          image!,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: _generateQRCodeFromCSV,
                child: Text(image == null
                    ? "Select Files and Generate QR Code"
                    : "Generate new QR Code")),
          ],
        ),
      ]),
    );
  }
}

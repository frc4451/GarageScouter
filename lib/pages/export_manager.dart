import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:robotz_garage_scouting/utils/hash_helpers.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';

/// Export Management Page for Mobile Devices that may not have wireless
/// communications (IE Fire Tablets) and solely provides a QR Code to make
/// data transfer easier for these offline devices.
///
/// NOTE: this will not support Web due to the usage of ml_dataframe. But
/// for those will be using the web app. They're not likely to use the export
/// manager anyway.
class ExportManagerPage extends StatefulWidget {
  const ExportManagerPage({super.key});

  @override
  State<ExportManagerPage> createState() => _ExportManagerPageState();
}

class _ExportManagerPageState extends State<ExportManagerPage> {
  QrImageView? image;

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
      errorMessageSnackbar(context, "No files selected. User aborted action.");
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
      image = QrImageView(
        data: encodeJsonToB64(fileData),
        version: QrVersions.auto,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(25.0),
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

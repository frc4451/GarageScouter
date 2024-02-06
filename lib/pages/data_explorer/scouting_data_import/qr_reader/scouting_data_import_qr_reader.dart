import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/router.dart';
import 'package:garagescouter/utils/hash_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class ScoutingDataQRReaderPage extends StatefulWidget {
  final GarageRouter scoutingRouter;

  const ScoutingDataQRReaderPage({super.key, required this.scoutingRouter});

  @override
  State<ScoutingDataQRReaderPage> createState() =>
      _ScoutingDataQRReaderPageState();
}

class _ScoutingDataQRReaderPageState extends State<ScoutingDataQRReaderPage> {
  bool _readingInput = true;

  void _cancel() {
    context.pop();
  }

  Future<void> _detectInput(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    setState(() {
      _readingInput = false;
    });

    final String discoveredData = barcodes[0].rawValue ?? "";

    final Map<String, dynamic> value = decodeJsonFromB64(discoveredData);

    final List<String> requiredKeys = ["type", "data"];

    for (final key in requiredKeys) {
      if (!value.containsKey(key)) {
        errorMessageSnackbar(context, "QR data does not include $key");

        setState(() {
          _readingInput = true;
        });
        return;
      }
    }

    final String dataType = value['type'];

    final Map<String, Type> typeOptions = {
      "Pit Scouting": PitScoutingEntry,
      "Match Scouting": MatchScoutingEntry,
      "Super Scouting": SuperScoutingEntry
    };

    // Sanity checks for looking at types we either don't expect,
    // or aren't the data type we care about at this time.
    if (!typeOptions.containsKey(dataType)) {
      await showDialog(
          context: context,
          builder: ((context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 16.0,
                insetPadding: const EdgeInsets.all(4.0),
                title:
                    const Text("QR Code came from an invalid type selection."),
                actions: [
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: _cancel, child: const Text("Close"))
                    ],
                  )
                ],
              )));
    } else if (dataType != widget.scoutingRouter.displayName) {
      await showDialog(
          context: context,
          builder: ((context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 16.0,
                insetPadding: const EdgeInsets.all(4.0),
                title: Text(
                    "You're trying to read data for ${widget.scoutingRouter.displayName}, but are looking at data from $dataType"),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: _cancel, child: const Text("Close"))
                    ],
                  )
                ],
              )));
    } else {
      await context.pushNamed(
          widget.scoutingRouter.getQRReaderResultsRouteName(),
          queryParameters: {"data": discoveredData});
    }

    setState(() {
      _readingInput = true;
    });

    // showGeneralDialog(
    //     context: context,
    //     pageBuilder: ((context, animation, secondaryAnimation) =>
    //         Column(children: [
    //           ...ListTile.divideTiles(
    //               tiles: entries.mapIndexed((index, element) => ListTile(
    //                     title: Text("Team Number: ${element.teamNumber}"),
    //                   ))).toList(),
    //           ElevatedButton(
    //               onPressed: () {
    //                 _isarModel.putAllScoutingData(entries);
    //                 context.pop();
    //               },
    //               child: const Text("Confirm")),
    //           ElevatedButton(
    //               onPressed: () {
    //                 context.pop();
    //               },
    //               child: const Text("Cancel")),
    //         ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        centerTitle: true,
      ),
      body: _readingInput
          ? MobileScanner(
              fit: BoxFit.contain,
              controller: MobileScannerController(
                returnImage: true,
              ),
              onDetect: _detectInput,
            )
          : null,
    );
  }
}

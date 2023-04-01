import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robotz_garage_scouting/utils/file_io_helpers.dart';

class PhotoCollectionPage extends StatefulWidget {
  const PhotoCollectionPage({super.key});

  @override
  State<PhotoCollectionPage> createState() => _PhotoCollectionPageState();
}

class _PhotoCollectionPageState extends State<PhotoCollectionPage> {
  final ImagePicker _picker = ImagePicker();

  final Map<String, File> _photos = {};

  final _formKey = GlobalKey<FormBuilderState>();

  void _kSuccessMessage(File file) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Successfully wrote file ${file.path}",
          textAlign: TextAlign.center,
        )));
  }

  void _kFailureMessage(error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        )));
  }

  /// Opens photo collecting dialog and adds it to the running
  /// Map that collects all images.
  Future<void> _takePictures(String tag) async {
    bool validInputs = _formKey.currentState?.saveAndValidate() ?? false;

    if (!validInputs) {
      _kFailureMessage("Enter the team number before you can collect photos.");
      return;
    }

    String teamNumber = _formKey.currentState?.value["team_number"];

    // ImagePicker opens the Photos app and does everything for us.
    XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) {
      _kFailureMessage("User aborted operation");
      return;
    }

    // We have to provide the name of the new file.
    File tempFile = File(photo.path);
    String finalpath = await generateUniqueFilePath(
        extension: getExtension(tempFile),
        prefix: "${teamNumber}_${tag}_photo");

    // Delete the file if the field already has an image
    if (await _photos[tag]?.exists() ?? false) {
      await _photos[tag]?.delete();
    }

    // Copy the file from the auto-generated file to something we
    // can digest and predict as a user.
    File finalFile = await copyFileToNewPath(tempFile, finalpath,
        extension: getExtension(tempFile));

    // Delete the original file since we don't need it. We care
    // about the one we moved with a predictable name.
    await tempFile.delete();

    setState(() {
      _photos[tag] = File(finalFile.path);
      _kSuccessMessage(_photos[tag]!);
    });
  }

  /// Handles the creation of ZIP files from all photo inputs. Opens the
  /// FilePicker UI using the same models we use for the other forms.
  Future<void> _createZip() async {
    try {
      _formKey.currentState?.save();
      String teamNumber = _formKey.currentState?.value['team_number'] ?? '';

      if (teamNumber.isEmpty) {
        _kFailureMessage("Team Number cannot be empty.");
        return;
      }

      if (_photos.isEmpty) {
        _kFailureMessage("No photos are selected.");
        return;
      }

      String prefix = "${teamNumber}_photo_collection";
      File zipFile =
          File(await generateUniqueFilePath(extension: "zip", prefix: prefix));

      await ZipFile.createFromFiles(
          sourceDir: await getApplicationSupportDirectory(),
          files: _photos.values.toList(),
          zipFile: zipFile);

      saveFileToDevice(zipFile).then((File file) {
        setState(() {
          _resetForm();
        });
        _kSuccessMessage(file);
      }).catchError(_kFailureMessage);
    } catch (e) {
      print('Error creating zip file: $e');
    }
  }

  /// Help clean up data we don't care about.
  /// Includes deleting photos not needed.
  void _resetForm() {
    _formKey.currentState?.reset();
    _photos.values.forEach((file) {
      file.deleteSync();
    });
    _photos.clear();
  }

  @override
  void dispose() {
    _resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Photo Collection",
            textAlign: TextAlign.center,
          ),
        ),
        body: CustomScrollView(slivers: <Widget>[
          SliverToBoxAdapter(
              child: Center(
            child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: "team_number",
                      decoration: const InputDecoration(
                          label: Text("Team Number"),
                          icon: Icon(Icons.numbers)),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(children: [
                        ElevatedButton(
                            onPressed: () async =>
                                await _takePictures("drive_train"),
                            child: const Text("Open Picture for Drive Train")),
                        Text(_photos["drive_train"]?.path != null
                            ? getBaseName(_photos["drive_train"]!)
                            : "Waiting for image..."),
                        if (_photos["drive_train"] != null &&
                            _photos["drive_train"]!.existsSync())
                          Image.file(_photos["drive_train"]!)
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(children: [
                        ElevatedButton(
                            onPressed: () async =>
                                await _takePictures("main_robot_game"),
                            child:
                                const Text("Open Picture for Main Robot View")),
                        Text(_photos["main_robot_game"]?.path != null
                            ? getBaseName(_photos["main_robot_game"]!)
                            : "Waiting for image..."),
                        if (_photos["main_robot_game"] != null &&
                            _photos["main_robot_game"]!.existsSync())
                          Image.file(_photos["main_robot_game"]!)
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(children: [
                        ElevatedButton(
                            onPressed: () async =>
                                await _takePictures("pit_exterior"),
                            child: const Text("Open Picture for Pit Exterior")),
                        Text(_photos["pit_exterior"]?.path != null
                            ? getBaseName(_photos["pit_exterior"]!)
                            : "Waiting for image..."),
                        if (_photos["pit_exterior"] != null &&
                            _photos["pit_exterior"]!.existsSync())
                          Image.file(_photos["pit_exterior"]!)
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: ElevatedButton(
                        onPressed: () async => _createZip(),
                        child: const Text("Download ZIP Archive"),
                      ),
                    ),
                  ],
                )),
          ))
        ]));
  }
}

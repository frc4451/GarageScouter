import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:garagescouter/components/forms/photo_form_field.dart';
import 'package:garagescouter/utils/file_io_helpers.dart';
import 'package:garagescouter/utils/notification_helpers.dart';

class PhotoCollectionPage extends StatefulWidget {
  const PhotoCollectionPage({super.key});

  @override
  State<PhotoCollectionPage> createState() => _PhotoCollectionPageState();
}

class _PhotoCollectionPageState extends State<PhotoCollectionPage> {
  final Map<String, File> _photos = {};
  final List<File> files = [];
  final Map<String, PhotoFormField> _optionalPhotosHash = {};

  final _formKey = GlobalKey<FormBuilderState>();

  Future<File> _convertXFileToFile(
      {required XFile xfile, required String tag}) async {
    String teamNumber = _formKey.currentState?.value["team_number"];

    // We have to provide the name of the new file.
    File tempFile = File(xfile.path);
    // File tempFile = File(_formKey.currentState?.value['image_test_field'].path);
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

    return finalFile;
  }

  /// @deprecated, but my end up being repurposed later to help with
  /// edge cases with non mobile devices like desktop/web.
  // /// Opens photo collecting dialog and adds it to the running
  // /// Map that collects all images.
  // Future<void> _takePictures(String tag) async {
  //   bool validInputs = _formKey.currentState?.saveAndValidate() ?? false;

  //   if (!validInputs) {
  //     _kFailureMessage("Enter the team number before you can collect photos.");
  //     return;
  //   }

  //   // ImagePicker opens the Photos app and does everything for us.
  //   final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

  //   if (photo == null) {
  //     _kFailureMessage("User aborted operation");
  //     return;
  //   }

  //   final File finalFile = await _convertXFileToFile(
  //       xfile: photo, tag: tag.replaceAll("_image", ""));

  //   setState(() {
  //     _photos[tag] = File(finalFile.path);
  //     _kSuccessFileSaveMessage(_photos[tag]!);
  //   });
  // }

  /// Adds a PhotoFormField to the PhotosHash we use to handle
  /// optional fields.
  void _addPhotoFormField({required String fieldName}) {
    setState(() {
      final PhotoFormField photoFormField = PhotoFormField(
        key: ObjectKey(fieldName),
        initialValue: fieldName,
      );
      _optionalPhotosHash[photoFormField.name] = photoFormField;
    });
  }

  void _removePhotoFormField({required String key}) {
    setState(() {
      _optionalPhotosHash.remove(key);
    });
  }

  void _showAddPictureDialog() async {
    String? fieldName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          String inputText = "";
          return AlertDialog(
            title: const Text(
              "Add New Image Field",
              textAlign: TextAlign.center,
            ),
            content: FormBuilderTextField(
              name: "new_image_form_name",
              decoration:
                  const InputDecoration(label: Text("Description of Picture")),
              onChanged: (value) {
                if (value != null) {
                  inputText = value;
                }
              },
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(inputText),
                      child: const Text("Add Field"))
                ],
              )
            ],
          );
        });

    if (fieldName != null && fieldName.isNotEmpty) {
      _addPhotoFormField(fieldName: fieldName);
    } else {
      if (!mounted) return;

      errorMessageSnackbar(
          context, "No input was provided. No new fields added.");
    }
  }

  /// Handles the creation of ZIP files from all photo inputs. Opens the
  /// FilePicker UI using the same models we use for the other forms.
  ///
  /// Some image fields may contain multiple images. That's totally fine.
  /// However, to make sure that we correctly assign the tags to each photo
  /// in each image picker field, we need to explicitly convert every XFile
  /// in each ImagePicker field and assign the name correctly and make a
  /// flat list for the ZipFile handler to correctly organize it.
  Future<void> _createZip() async {
    try {
      bool isValid = _formKey.currentState?.saveAndValidate() ?? false;

      if (!isValid) {
        errorMessageSnackbar(context,
            "Not all fields are completed, please fill the form and resubmit.");
        return;
      }

      final String teamNumber =
          _formKey.currentState?.value['team_number'] ?? '';

      if (teamNumber.isEmpty) {
        errorMessageSnackbar(context, "Team Number cannot be empty.");
        return;
      }

      final List<File> files = [];
      for (final key in _formKey.currentState!.fields.keys) {
        final value = _formKey.currentState!.fields[key];
        if (value?.widget is FormBuilderImagePicker) {
          for (final XFile xfile in value?.value) {
            final String tag = key.replaceAll("image_", "");
            final File file = await _convertXFileToFile(xfile: xfile, tag: tag);
            files.add(file);
          }
        }
      }

      if (files.isEmpty) {
        if (!mounted) return;

        errorMessageSnackbar(context, "No images were provided.");
        return;
      }

      final String prefix = "${teamNumber}_photo_collection";
      final File zipFile =
          File(await generateUniqueFilePath(extension: "zip", prefix: prefix));

      await ZipFile.createFromFiles(
          sourceDir: await getApplicationSupportDirectory(),
          files: files,
          zipFile: zipFile);

      saveFileToDevice(zipFile).then((File file) {
        setState(() {
          _resetForm();
        });
        errorMessageSnackbar(context, file);
      }).catchError((exception) {
        errorMessageSnackbar(context, exception);
      });
    } catch (e) {
      if (!mounted) return;

      errorMessageSnackbar(context, e.toString());
    }
  }

  /// Help clean up data we don't care about.
  /// Includes deleting photos not needed.
  void _resetForm() {
    _formKey.currentState?.reset();
    for (final file in _photos.values) {
      file.deleteSync();
    }
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
        title: const Text("Photo Collection"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _showAddPictureDialog,
              icon: const Icon(Icons.add_a_photo))
        ],
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
                        label: Text("Team Number"), icon: Icon(Icons.numbers)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.required(),
                  ),
                  const PhotoFormField(
                    initialValue: "Drive Train",
                  ),
                  const PhotoFormField(
                    initialValue: "Robot Front View",
                  ),
                  const PhotoFormField(
                    initialValue: "Pit View",
                    maxImages: 3,
                  ),
                  ..._optionalPhotosHash.values
                      .map((PhotoFormField photoField) => Column(
                            children: [
                              photoField,
                              OutlinedButton(
                                  onPressed: () {
                                    _removePhotoFormField(key: photoField.name);
                                  },
                                  child: const Text("Remove from Form"))
                            ],
                          )),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async => _createZip(),
                            child: const Text("Download ZIP Archive")),
                      ],
                    ),
                  )
                ],
              )),
        ))
      ]),
    );
  }
}

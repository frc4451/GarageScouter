import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

/// PhotoFormField so we can easily organize Photo Inputs on the
/// Photo Collection Page.
///
/// Because of the unreliability of names in variable form fields,
/// we implement the `get` syntax of Dart to allow us to create sanitized
/// `name` variables for the form fields and to be used as a map key in the
/// Photo Collection tool. You _do not_ pass `name` to this component. It will
/// be inferred from the `initialValue` prop.
class PhotoFormField extends StatefulWidget {
  final String initialValue;

  final bool readOnly;
  final int maxImages;
  final bool required;

  const PhotoFormField(
      {super.key,
      required this.initialValue,
      this.readOnly = true,
      this.maxImages = 3,
      this.required = false});

  String get name => sanitizeFilename(initialValue.toLowerCase());

  @override
  State<PhotoFormField> createState() => _PhotoFormFieldState();
}

class _PhotoFormFieldState extends State<PhotoFormField> {
  @override
  Widget build(BuildContext context) {
    const double x = 0;
    const double y = 10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(x, y, x, y),
      child: Column(children: [
        FormBuilderTextField(
          name: "text_${widget.name}",
          decoration: const InputDecoration(
            label: Text("Description of Picture"),
            icon: Icon(Icons.camera_alt),
          ),
          validator: FormBuilderValidators.required(),
          readOnly: widget.readOnly,
          initialValue: widget.initialValue,
        ),
        FormBuilderImagePicker(
          name: "image_${widget.name}",
          validator: FormBuilderValidators.required(),
          decoration: const InputDecoration(
            labelText: 'Pick Photos',
          ),
          maxImages: widget.maxImages,
        ),
      ]),
    );
  }
}

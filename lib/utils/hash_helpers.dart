import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

/// Takes a List of Strings and creates a Map<String, dynamic> where the keys are
/// the list values and the values are set to 'null'
///
/// Accepts a null reference to account for FormBuilderState.
Map<String, dynamic> convertListToDefaultMap(Iterable<String>? list,
        {String? value}) =>
    {for (final key in list ?? const Iterable.empty()) key: value};

/// We don't have a native way in Dart to reset a non-null value to
/// each non string element. So for types we expect, we've implemented
/// a basic 'reset' function to clear the form state.
Map<String, dynamic> createEmptyFormState(Map<String, dynamic> form) {
  Map<Type, dynamic> defaultValues = {bool: false, String: null};

  Map<String, dynamic> defaultForm = {};

  for (final key in form.keys) {
    defaultForm[key] = defaultValues[form[key].runtimeType];
  }

  return defaultForm;
}

/// Takes a Map<String, dynamic> object we want to convert to Json,
/// encodes it to UTF8 -> GZIP Compression -> B64 string so we can
/// reduce the overall footprint of the text data being sent over
/// QR Codes
///
/// Optionally, you can specify `urlSafe` in order to enforce that the b64
/// string is compatible with URI paths in GoRouter
String encodeJsonToB64(Map<String, dynamic> json, {bool urlSafe = false}) {
  String jsonEncodedString = jsonEncode(json);
  List<int> utf8Bytes = utf8.encode(jsonEncodedString);
  List<int> gzipCompression = gzip.encode(utf8Bytes);

  String b64String = urlSafe
      ? base64UrlEncode(gzipCompression)
      : base64Encode(gzipCompression);

  return b64String;
}

/// Extension of `encodeJsonToB64` to allow multiple Maps to be encoded
/// to a singular string. Does the same thing but with a different
/// parameter type.
String encodeMultipleJsonToB64(List<Map<String, dynamic>> json,
    {bool urlSafe = false}) {
  String jsonEncodedString = jsonEncode(json);
  List<int> utf8Bytes = utf8.encode(jsonEncodedString);
  List<int> gzipCompression = gzip.encode(utf8Bytes);

  String b64String = urlSafe
      ? base64UrlEncode(gzipCompression)
      : base64Encode(gzipCompression);

  return b64String;
}

/// Receives a B64 encoded string (assuming generated from encodeJsonForQRCode)
/// and reverses the process to convert B64 -> GZIP Decompression -> UTF8 decode
/// so we can reduce the amount of text over QR Codes
Map<String, dynamic> decodeJsonFromB64(String data) {
  if (data.isEmpty) {
    return {};
  }

  List<int> b64decompression = base64Decode(data);
  List<int> gzipDecompression = gzip.decode(b64decompression);
  String utf8String = utf8.decode(gzipDecompression);
  Map<String, dynamic> json = jsonDecode(utf8String);
  return json;
}

String convertMapStateToString(Map<String, dynamic> state) =>
    const ListToCsvConverter()
        .convert([state.keys.toList(), state.values.toList()]);

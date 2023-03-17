import 'dart:convert';
import 'dart:io';

/// Takes a List of Strings and creates a Map<String, dynamic> where the keys are
/// the list values and the values are set to 'null'
///
/// Accepts a null reference to account for FormBuilderState.
Map<String, dynamic> convertListToDefaultMap(Iterable<String>? list,
        {String? value}) =>
    {for (final key in list ?? const Iterable.empty()) key: value};

/// Takes a Map<String, dynamic> object we want to convert to Json,
/// encodes it to UTF8 -> GZIP Compression -> B64 string so we can
/// reduce the overall footprint of the text data being sent over
/// QR Codes
String encodeJsonForQRCode(Map<String, dynamic> json) {
  String jsonEncodedString = jsonEncode(json);
  List<int> utf8Bytes = utf8.encode(jsonEncodedString);
  List<int> gzipCompression = gzip.encode(utf8Bytes);
  String b64String = base64Encode(gzipCompression);
  return b64String;
}

/// Receives a B64 encoded string (assuming generated from encodeJsonForQRCode)
/// and reverses the process to convert B64 -> GZIP Decompression -> UTF8 decode
/// so we can reduce the amount of text over QR Codes
Map<String, dynamic> decodeJsonFromQRCode(String data) {
  List<int> b64decompression = base64Decode(data);
  List<int> gzipDecompression = gzip.decode(b64decompression);
  String utf8String = utf8.decode(gzipDecompression);
  Map<String, dynamic> json = jsonDecode(utf8String);
  return json;
}

import 'package:intl/intl.dart';

extension FormatDateTime on DateTime {
  /// Wrapper for DateTime Formatting. For reference, read the docs
  /// https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  String getFormattedDateTime(String format) => DateFormat(format).format(this);

  /// Shorthand for a human readable formatted datetime string.
  String standardizedFormat() => getFormattedDateTime("MMMM dd y, hh:mm a");
}

extension CapitalizationExtension on String {
  /// Capitalize every word by splitting via spaces.
  /// This will not lowercase any characters.
  /// Example: `"real words here" -> "Real Words Here"`
  String capitalize() {
    return split(" ").map((s) => s.capitalizeFirst()).join(" ");
  }

  /// Capitalize first character.
  /// This will not lowercase any characters.
  /// Example: `"real words here" -> "Real words here"`
  String capitalizeFirst() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension CheckEmptiness on Map {
  /// Confirms that every value in the Map has a value, and that none are `null`
  bool isEveryValueEmpty() {
    if (isEmpty) {
      return true;
    }
    return values.every((value) => value == null);
  }

  /// Returns `true` if the value of the `key` prop is null.
  bool valueForKeyIsNull(dynamic key) => this[key] == null;

  /// Returns `true` if the value of the `key` prop is not null.
  bool valueForKeyIsNotNull(dynamic key) => this[key] != null;
}

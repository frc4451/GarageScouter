isNumeric() {
  return (value) {
    final int? number = int.tryParse(value!);
    if (number == null || number < 1) {
      return "Team Number needs to be a Postive Number";
    }
    return null;
  };
}

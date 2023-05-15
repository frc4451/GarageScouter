/// Helps determine direction when using PageView controllers
enum PageDirection {
  left(-1),
  right(1),
  none(0);

  final int value;

  const PageDirection(this.value);
}

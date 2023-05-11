/// Helps determine direction when using PageView controllers
enum PageDirection {
  left,
  right,
  none;

  int get value {
    switch (this) {
      case PageDirection.left:
        return -1;
      case PageDirection.right:
        return 1;
      case PageDirection.none:
        return 0;
    }
  }
}

/// Enables us to assume that directions have values
// extension PageExtension on PageDirection {
//   int get value {
//     switch (this) {
//       case PageDirection.left:
//         return -1;
//       case PageDirection.right:
//         return 1;
//       case PageDirection.none:
//         return 0;
//     }
//   }
// }

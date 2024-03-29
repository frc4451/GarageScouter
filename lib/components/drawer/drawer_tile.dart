import 'package:flutter/material.dart';

/// Drawer Tile Widget designed to help make consistent Tiles on
/// the Drawer. Eventually we can add additional styling and whatever.
class DrawerTile extends StatelessWidget {
  final String tileText;
  final void Function()? onTap;

  const DrawerTile({super.key, required this.tileText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tileText),
      onTap: onTap,
    );
  }
}

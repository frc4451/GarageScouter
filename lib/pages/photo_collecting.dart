import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PhotoCollectionPage extends StatefulWidget {
  const PhotoCollectionPage({super.key});

  @override
  State<PhotoCollectionPage> createState() => _PhotoCollectionPageState();
}

class _PhotoCollectionPageState extends State<PhotoCollectionPage> {
  final String title = "Photo Collection Tool";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        title: Text(title),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [Text(title)],
        ),
      )
    ]));
  }
}

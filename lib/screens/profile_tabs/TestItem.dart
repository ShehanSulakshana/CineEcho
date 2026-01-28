import 'package:flutter/material.dart';

class Testitem extends StatelessWidget {
  final int itemno;
  const Testitem({super.key, required this.itemno});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("TEXT $itemno"));
  }
}

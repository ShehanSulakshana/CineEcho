import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(child: Text("GENRE")),
    );
  }
}

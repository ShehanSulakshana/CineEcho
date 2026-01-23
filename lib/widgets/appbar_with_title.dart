import 'package:flutter/material.dart';

class AppbarWithTitle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppbarWithTitle({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  void _close(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
      leading: IconButton(
        onPressed: () => _close(context),
        icon: Icon(Icons.arrow_back_ios_new_rounded),
      ),
      title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: true,
    );
  }
}

import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final String type;
  final TextEditingController controller;

  const TextFieldWidget({
    super.key,
    required this.hintText,
    required this.type,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      //type == 'email' ? TextInputType.emailAddress : type=='password' ? TextInputType.visiblePassword ,
      //controller: controller,
      cursorColor: Theme.of(context).primaryColor,
      textAlignVertical: TextAlignVertical.center,
      style: Theme.of(context).textTheme.bodySmall,

      decoration: InputDecoration(
        labelText: hintText,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
      ),
    );
  }
}

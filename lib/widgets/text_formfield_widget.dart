import 'package:flutter/material.dart';

enum FieldType { email, password, text }

class TextFormFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FieldType? fieldType;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const TextFormFieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.fieldType,
    this.validator,
    this.keyboardType,
  });

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.fieldType == FieldType.password;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValidator =
        widget.validator ??
        _defaultValidator(widget.fieldType, widget.hintText);
    final effectiveKeyboardType =
        widget.keyboardType ?? _getKeyboardType(widget.fieldType);
    final isPassword = widget.fieldType == FieldType.password;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: effectiveKeyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: Theme.of(context).primaryColor,
      textAlignVertical: TextAlignVertical.center,
      style: Theme.of(context).textTheme.bodySmall,
      validator: effectiveValidator,
      decoration: InputDecoration(
        labelText: widget.hintText,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }

  // _getKeyboardType and _defaultValidator unchanged from previous
  TextInputType? _getKeyboardType(FieldType? type) {
    return switch (type) {
      FieldType.email => TextInputType.emailAddress,
      FieldType.password => TextInputType.visiblePassword,
      FieldType.text => TextInputType.text,
      _ => null,
    };
  }

  String? Function(String?)? _defaultValidator(FieldType? type, String hint) {
    return switch (type) {
      FieldType.email =>
        (v) => (v?.isEmpty ?? true)
            ? 'Email required'
            : (!v!.contains('@') ? 'Invalid email' : null),
      FieldType.password =>
        (v) => (v?.length ?? 0) < 8 ? 'Password must be 8+ chars' : null,
      FieldType.text => (v) => (v?.isEmpty ?? true) ? '$hint required' : null,
      _ => (v) => (v?.isEmpty ?? true) ? '$hint required' : null,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool initialObscureText;
  final void Function(String)? onChanged;

  const PasswordTextField({
    super.key,
    required this.hintText,
    this.label,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.initialObscureText = true,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late final ValueNotifier<bool> _obscureText;
  late final ValueNotifier<bool> _isFocused;

  @override
  void initState() {
    super.initState();
    _obscureText = ValueNotifier<bool>(widget.initialObscureText);
    _isFocused = ValueNotifier<bool>(false);

    widget.focusNode?.addListener(() {
      _isFocused.value = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    _obscureText.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _obscureText,
      builder: (context, obscureValue, child) {
        return ValueListenableBuilder(
          valueListenable: _isFocused,
          builder: (context, focusValue, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: obscureValue,
              validator:
                  widget.validator ??
                  (value) => Validators.validatePassword(value ?? ''),
              onFieldSubmitted: widget.onFieldSubmitted,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,

              enabled: widget.enabled,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: widget.hintText,
                label: widget.label != null ? Text(widget.label!) : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureValue ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    _obscureText.value = !_obscureText.value;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

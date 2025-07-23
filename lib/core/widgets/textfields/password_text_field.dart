import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? margin, padding;
  final bool enabled,initialObscureText;
  const PasswordTextField({
    super.key,
  
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.onFieldSubmitted,

    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.margin,
    required this.enabled,
    this.padding,  this.initialObscureText = true,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
    late final ValueNotifier<bool> _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = ValueNotifier<bool>(widget.initialObscureText);
  }

  @override
  void dispose() {
    _obscureText.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _obscureText,
      builder: (context,value,child) {
        return TextFormField(
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          obscureText: widget.initialObscureText,
          onFieldSubmitted: widget.onFieldSubmitted,
          keyboardType: TextInputType.visiblePassword,
          validator:(p0){
         return   Validators.validatePassword(p0 ?? '');
          },
          controller: widget.controller,
          focusNode: widget.focusNode,
          cursorColor: Theme.of(context).colorScheme.onSurface,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                value ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                _obscureText.value = !_obscureText.value;
              },
            ),
          
          ),
        );
      }
    );
  }
}

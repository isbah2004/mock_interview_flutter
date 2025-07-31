import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReusableTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefix, suffix;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final TextInputType keyboardType;
  final bool? obscureText;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  final bool enabled;
  final void Function(String)? onChanged;
  const ReusableTextField({
    super.key,
    this.prefix,
    this.suffix,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    required this.keyboardType,
    this.obscureText,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,

    required this.enabled,
this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 370,
      
      child: TextFormField(onChanged: onChanged,
        enabled: enabled,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        obscureText: obscureText ?? false,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefix,
          suffixIcon: suffix,
        
        ),
      ),
    );
  }
}

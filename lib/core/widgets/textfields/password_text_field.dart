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
  final bool enabled, initialObscureText;
  
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
    this.padding,
    this.initialObscureText = true,
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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: focusValue
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                enabled: widget.enabled,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines,
                obscureText: obscureValue,
                onFieldSubmitted: widget.onFieldSubmitted,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) => Validators.validatePassword(value ?? ''),
                controller: widget.controller,
                focusNode: widget.focusNode,
                cursorColor: Theme.of(context).colorScheme.primary,
                maxLength: widget.maxLength,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: focusValue 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureValue ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      _obscureText.value = !_obscureText.value;
                    },
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

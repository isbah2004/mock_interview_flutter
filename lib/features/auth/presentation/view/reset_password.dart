import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
import 'package:mock_interview/core/widgets/textfields/password_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacityCompat(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(AppImages.logo, height: 80, width: 80),
                ),
                const SizedBox(height: 32),

                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Create a new password for your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacityCompat(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                PasswordTextField(
                  hintText: 'New Password',
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  enabled: true,
                ),
                const SizedBox(height: 20),

                PasswordTextField(
                  hintText: 'Confirm New Password',
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  enabled: true,
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  onTap: _handlePasswordReset,
                  title: 'Update Password',
                  isLoading: false,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePasswordReset() {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle password reset logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password updated successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

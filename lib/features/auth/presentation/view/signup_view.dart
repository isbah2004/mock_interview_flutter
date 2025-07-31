import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';

import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
import 'package:mock_interview/core/widgets/buttons/social_auth_button.dart';
import 'package:mock_interview/core/widgets/dividers/or_divider.dart';
import 'package:mock_interview/core/widgets/textfields/password_text_field.dart';
import 'package:mock_interview/core/widgets/textfields/reusable_text_fields.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          log('AuthState: $state');
          if (state is AuthAuthenticated) {
            Navigator.pushNamed(context, AppRoutes.home); 
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Image.asset(
                        AppImages.logo,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Create Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign up to get started with your mock interviews',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ReusableTextField(
                      hintText: 'Full Name',
                      controller: nameController,
                      focusNode: nameFocusNode,
                      keyboardType: TextInputType.name,
                      enabled: !isLoading,
                      prefix: Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ReusableTextField(
                      prefix: const Icon(Icons.alternate_email_outlined),

                      hintText: 'Email',
                      controller: emailController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator:
                          (value) => Validators.validateEmail(value ?? ''),
                    ),
                    const SizedBox(height: 20),
                    PasswordTextField(
                      hintText: 'Password',
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 20),
                    PasswordTextField(
                      hintText: 'Confirm Password',
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocusNode,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      onTap: () => _handleSignup(),
                      title: 'Create Account',
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 30),
                    // Social auth section commented out as requested
                    const ORDivider(),
                    const SizedBox(height: 30),
                    // Disable social auth for now as requested
                    SocialAuthButton(
                      onTap: () {
                        context.read<AuthBloc>().add(
                          AuthGoogleSignInRequested(),
                        );
                      },
                      title: 'Continue with Google',
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              isLoading
                                  ? null
                                  : () {
                                    Navigator.pushNamed(context, AppRoutes.login);
                                  },
                          child: Text(
                            ' Login',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  isLoading
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      context.read<AuthBloc>().add(
        AuthSignUpRequested(name: name, email: email, password: password),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/enums/social_auth_type.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
import 'package:mock_interview/core/widgets/buttons/social_auth_button.dart';
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

class _SignupViewState extends State<SignupView>
    with TickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset(
                                  AppImages.logo,
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Create Account',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join us and start your journey',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        ReusableTextField(
                          hintText: 'Full Name',
                          controller: nameController,
                          focusNode: nameFocusNode,
                          keyboardType: TextInputType.name,
                          enabled: !isLoading,
                          prefix: Icon(Icons.person_outline),
                          // validator: (value) => Validators.validateName(value ?? ''),
                        ),
                        const SizedBox(height: 20),

                        ReusableTextField(
                          hintText: 'Email Address',
                          controller: emailController,
                          focusNode: emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          prefix: Icon(Icons.email_outlined),
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
                        const SizedBox(height: 32),

                        PrimaryButton(
                          onTap: _handleSignup,
                          title: 'Create Account',
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SocialAuthButton(
                          type: SocialAuthType.google,
                          onTap: () => _handleSocialAuth(SocialAuthType.google),
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),

                        SocialAuthButton(
                          type: SocialAuthType.facebook,
                          onTap:
                              () => _handleSocialAuth(SocialAuthType.facebook),
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  isLoading
                                      ? null
                                      : () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.login,
                                      ),
                              child: Text(
                                'Sign In',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      isLoading
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.4)
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
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

  void _handleSocialAuth(SocialAuthType type) {
    if (type == SocialAuthType.google) {
      context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
    } else if (type == SocialAuthType.facebook) {
      context.read<AuthBloc>().add(const AuthFacebookSignInRequested());
    }
  }
}

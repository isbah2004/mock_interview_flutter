import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/enums/social_auth_type.dart';
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

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

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
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamed(context, AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.08),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Image.asset(
                                  AppImages.logo,
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Welcome Back!',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue your mock interview journey',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Email Field
                        ReusableTextField(
                          label: 'Email Address',
                          hintText: 'Enter your email',
                          controller: emailController,
                          focusNode: emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          prefix: Icon(
                            Icons.email_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          validator:
                              (value) => Validators.validateEmail(value ?? ''),
                          onFieldSubmitted: (value) {
                            Validators.fieldFocusChange(
                              context,
                              emailFocusNode,
                              passwordFocusNode,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Password Field
                        PasswordTextField(
                          hintText: 'Enter your password',
                          controller: passwordController,
                          focusNode: passwordFocusNode,

                          enabled: !isLoading,
                        ),

                        const SizedBox(height: 16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.forgotPassword,
                                      );
                                    },
                            child: Text(
                              'Forgot Password?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Button
                        PrimaryButton(
                          onTap: _handleLogin,
                          title: 'Sign In',
                          isLoading: isLoading,
                          icon: Icons.login,
                        ),

                        const SizedBox(height: 32),

                        // Divider
                        const ORDivider(),

                        const SizedBox(height: 32),

                        // Social Auth Buttons
                        SocialAuthButton(
                          onTap: () {
                            context.read<AuthBloc>().add(
                              AuthGoogleSignInRequested(),
                            );
                          },
                          isLoading: false,
                          type: SocialAuthType.google,
                        ),

                        const SizedBox(height: 16),

                        SocialAuthButton(
                          onTap: () {
                            context.read<AuthBloc>().add(
                              const AuthFacebookSignInRequested(),
                            );
                          },
                          isLoading: false,
                          type: SocialAuthType.facebook,
                        ),

                        const SizedBox(height: 32),

                        // Sign Up Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap:
                                        isLoading
                                            ? null
                                            : () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.register,
                                              );
                                            },
                                    child: Text(
                                      'Sign Up',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      context.read<AuthBloc>().add(
        AuthSignInRequested(email: email, password: password),
      );
    }
  }
}

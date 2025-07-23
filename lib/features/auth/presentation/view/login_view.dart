import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/navigation/navigation_service.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
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

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            NavigationService.goToHome();
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.asset(AppImages.logo, height: 175),
                    const SizedBox(height: 30),
                    ReusableTextField(
                      onFieldSubmitted: (value) {
                        Validators.fieldFocusChange(
                          context,
                          emailFocusNode,
                          passwordFocusNode,
                        );
                      },
                      prefix: const Icon(Icons.alternate_email_outlined),
                      hintText: 'Email',
                      controller: emailController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator: (p0) {
                        return Validators.validateEmail(p0 ?? '');
                      },
                    ),
                    const SizedBox(height: 30),
                    PasswordTextField(
                      hintText: 'Password',
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      enabled: !isLoading,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: GestureDetector(
                          onTap:
                              isLoading
                                  ? null
                                  : () {
                                    NavigationService.navigateToResetPassword();
                                  },
                          child: Text(
                            textAlign: TextAlign.end,
                            'Forgot Password?',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color:
                                  isLoading
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      onTap: () => _handleLogin(),
                      title: 'Login',
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 30),
                    // Social auth section commented out as requested
                    // const ORDivider(),
                    // const SizedBox(height: 30),
                    // Disable social auth for now as requested
                    // SocialAuthButton(
                    //   onTap: isLoading ? null : _handleGoogleSignIn,
                    //   title: 'Continue with Google',
                    //   iconPath: AppImages.googleIcon,
                    // ),
                    // const SizedBox(height: 15),
                    // SocialAuthButton(
                    //   onTap: isLoading ? null : _handleFacebookSignIn,
                    //   title: 'Continue with Facebook',
                    //   iconPath: AppImages.facebookIcon,
                    // ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
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
                                    NavigationService.goToSignup();
                                  },
                          child: Text(
                            ' Signup',
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

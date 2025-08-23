import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/utils/validators/validators.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
import 'package:mock_interview/core/widgets/textfields/reusable_text_fields.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() =>
      _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

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
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password reset email sent successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pushNamed(context, AppRoutes.login);
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
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Forgot Password?',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        ReusableTextField(
                          hintText: 'Email Address',
                          controller: emailController,
                          focusNode: emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          
                          prefix:Icon( Icons.email_outlined),
                          validator:
                              (value) => Validators.validateEmail(value ?? ''),
                        ),
                        const SizedBox(height: 32),

                        PrimaryButton(
                          onTap: _handlePasswordReset,
                          title: 'Send Reset Link',
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remember your password? ',
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

  void _handlePasswordReset() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = emailController.text.trim();
      context.read<AuthBloc>().add(AuthPasswordResetRequested(email: email));
    }
  }
}

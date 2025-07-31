import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/widgets/buttons/primary_button.dart';
import 'package:mock_interview/core/widgets/textfields/password_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Image.asset(AppImages.logo, height: 250),

              PasswordTextField(
                hintText: 'New Password',
                controller: passwordController,
                enabled: true,
              ),
              const SizedBox(height: 30),

              PrimaryButton(onTap: () {}, title: 'Submit', isLoading: false),
            ],
          ),
        ),
      ),
    );
  }
}

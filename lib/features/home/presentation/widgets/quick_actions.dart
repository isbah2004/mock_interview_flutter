import 'package:flutter/material.dart';
import 'package:mock_interview/core/constants/app_strings.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/features/home/presentation/widgets/interview_button.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SectionHeader(title: AppStrings.startNewInterview),
        // const SizedBox(height: 16),

        // Voice Interview Button
        InterviewButton(
          title: AppStrings.voiceInterview,
          subtitle: AppStrings.voiceInterviewSubtitle,
          icon: Icons.mic,
          type: InterviewButtonType.primary,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.voiceInterviewSetupView);
          },
        ),

        // MCQ Interview Button
        InterviewButton(
          title: AppStrings.mcqInterview,
          subtitle: AppStrings.mcqInterviewSubtitle,
          icon: Icons.book,
          type: InterviewButtonType.secondary,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.mcqInterviewSetupView);
          },
        ),

        // // Test Ads Button (Development/Testing only)
        // if (const bool.fromEnvironment('dart.vm.product') == false)
        //   InterviewButton(
        //     title: 'Test Ads',
        //     subtitle: 'Test Facebook Audience Network integration',
        //     icon: Icons.monetization_on,
        //     type: InterviewButtonType.secondary,
        //     onPressed: () {
        //       Navigator.pushNamed(context, AppRoutes.adsTest);
        //     },
        //   ),
      ],
    );
  }
}

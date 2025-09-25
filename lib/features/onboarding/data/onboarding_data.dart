import 'package:flutter/material.dart';
import 'package:mock_interview/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';

class OnboardingData {
  static List<OnboardingPage> getOnboardingPages() {
    return [
      const OnboardingPage(
        title: 'Welcome to Mockee',
        description:
            'Master your next interview with AI-powered practice sessions. Get ready to boost your confidence and land your dream job!',
        icon: Icons.star_rounded,
        iconColor: AppColors.primaryPurple,
      ),
      const OnboardingPage(
        title: 'Voice Interviews',
        description:
            'Practice speaking naturally with our AI interviewer. Get real-time feedback on your communication skills and interview responses.',
        icon: Icons.mic_rounded,
        iconColor: AppColors.primaryPurple,
      ),
      const OnboardingPage(
        title: 'MCQ Practice',
        description:
            'Test your knowledge with multiple-choice questions tailored to your field. Track your progress and identify areas for improvement.',
        icon: Icons.quiz_rounded,
        iconColor: AppColors.primaryPurple,
      ),
      const OnboardingPage(
        title: 'Smart Analytics',
        description:
            'Get detailed performance insights and personalized recommendations. Monitor your progress and see your improvement over time.',
        icon: Icons.analytics_rounded,
        iconColor: AppColors.primaryPurple,
      ),
      const OnboardingPage(
        title: 'Ready to Start?',
        description:
            'Everything is set up! Let\'s begin your interview preparation journey and help you achieve your career goals.',
        icon: Icons.rocket_launch_rounded,
        iconColor: AppColors.primaryPurple,
      ),
    ];
  }
}

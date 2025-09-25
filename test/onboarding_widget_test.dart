import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_interview/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:mock_interview/features/onboarding/domain/entities/onboarding_page.dart';

void main() {
  testWidgets('Onboarding page renders without overflow', (
    WidgetTester tester,
  ) async {
    final page = OnboardingPage(
      title: 'Welcome',
      description:
          'A short description to test layout behavior on small screens.',
      icon: Icons.star,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 568, // typical small device
            child: OnboardingPageWidget(
              page: page,
              isActive: true,
              pageIndex: 0,
            ),
          ),
        ),
      ),
    );

    // Avoid pumpAndSettle because the widget has repeating animations; pump a short duration instead
    await tester.pump(const Duration(milliseconds: 500));

    // Ensure no overflow text/exception — look for the title text
    expect(find.text('Welcome'), findsOneWidget);
  });
}

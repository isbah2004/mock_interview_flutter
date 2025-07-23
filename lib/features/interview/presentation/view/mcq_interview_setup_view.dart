import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/navigation/navigation_service.dart';
import 'package:mock_interview/core/widgets/textfields/reusable_text_fields.dart';
import '../widgets/setting_card_widget.dart';
import '../widgets/preview_item_widget.dart';
import '../widgets/mcq_info_card_widget.dart';
import '../cubit/mcq_setup_cubit.dart';
import '../cubit/mcq_setup_state.dart';

class MCQInterviewSetupScreen extends StatefulWidget {
  const MCQInterviewSetupScreen({super.key});

  @override
  State<MCQInterviewSetupScreen> createState() =>
      _MCQInterviewSetupScreenState();
}

class _MCQInterviewSetupScreenState extends State<MCQInterviewSetupScreen> {
  TextEditingController controller = TextEditingController();

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> questionCounts = [
    '5 Questions',
    '10 Questions',
    '15 Questions',
    '20 Questions',
  ];
  final List<String> categories = [
    'General',
    'Technical',
    'Behavioral',
    'Industry Specific',
  ];
  final List<String> timeLimits = [
    '15 seconds',
    '30 seconds',
    '45 seconds',
    '60 seconds',
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to text controller to update cubit
    controller.addListener(() {
      // We'll handle this in the build method using BlocBuilder
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MCQSetupCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BlocBuilder<MCQSetupCubit, MCQSetupState>(
                    builder: (context, state) {
                      final cubit = context.read<MCQSetupCubit>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF374151),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'MCQ Interview Setup',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 36),
                            ],
                          ),
        
                          SizedBox(height: 20),
                          const MCQInfoCardWidget(),
                          const SizedBox(height: 32),
        
                          // Quiz Settings
                          const Text(
                            'Quiz Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      color: const Color(0xFF374151),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Job Role',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter the job role for the interview',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 45,
                                  child: ReusableTextField(
                                    onChanged: cubit.updateJobRole,
        
                                    hintText: '',
                                    controller: controller,
                                    keyboardType: TextInputType.text,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Difficulty
                          SettingCardWidget(
                            title: 'Difficulty Level',
                            subtitle: 'Choose your preferred difficulty',
                            icon: Icons.trending_up,
                            options: difficulties,
                            selectedValue: cubit.currentDifficulty,
                            onChanged: cubit.updateDifficulty,
                          ),
                          const SizedBox(height: 16),
        
                          // Number of Questions
                          SettingCardWidget(
                            title: 'Number of Questions',
                            subtitle: 'How many questions do you want?',
                            icon: Icons.format_list_numbered,
                            options: questionCounts,
                            selectedValue: cubit.currentQuestions,
                            onChanged: cubit.updateQuestions,
                          ),
                          const SizedBox(height: 16),
        
                          // Category
                          SettingCardWidget(
                            title: 'Category',
                            subtitle: 'Select question focus area',
                            icon: Icons.category,
                            options: categories,
                            selectedValue: cubit.currentCategory,
                            onChanged: cubit.updateCategory,
                          ),
                          const SizedBox(height: 16),
        
                          // Time Limit
                          SettingCardWidget(
                            title: 'Time per Question',
                            subtitle: 'Set time limit for each question',
                            icon: Icons.timer,
                            options: timeLimits,
                            selectedValue: cubit.currentTimeLimit,
                            onChanged: cubit.updateTimeLimit,
                          ),
                          const SizedBox(height: 32),
        
                          // Quiz Preview
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.preview,
                                      color: Color(0xFF374151),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Quiz Preview',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                PreviewItemWidget(
                                  label: 'Job Role',
                                  value:
                                      cubit.currentJobRole.isEmpty
                                          ? 'Not specified'
                                          : cubit.currentJobRole,
                                ),
                                PreviewItemWidget(
                                  label: 'Difficulty',
                                  value: cubit.currentDifficulty,
                                ),
                                PreviewItemWidget(
                                  label: 'Questions',
                                  value: cubit.currentQuestions,
                                ),
                                PreviewItemWidget(
                                  label: 'Category',
                                  value: cubit.currentCategory,
                                ),
                                PreviewItemWidget(
                                  label: 'Time Limit',
                                  value: cubit.currentTimeLimit,
                                ),
                                PreviewItemWidget(
                                  label: 'Estimated Duration',
                                  value: cubit.calculateDuration(
                                    cubit.currentQuestions,
                                    cubit.currentTimeLimit,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
        
                          // Start Quiz Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Pass the selected values as parameters
                                NavigationService.navigateToMCQInterview(
                                  jobRole: cubit.currentJobRole,
                                  difficulty: cubit.getDifficultyEnum(),
                                  category: cubit.getCategoryEnum(),
                                  numberOfQuestions:
                                      cubit.getNumberOfQuestions(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF374151),
                                      Color(0xFF4B5563),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Start MCQ Interview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

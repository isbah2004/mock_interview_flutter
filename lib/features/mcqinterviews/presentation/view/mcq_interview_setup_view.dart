import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'mcq_interview_view.dart';
import '../bloc/unified_mcq_interview_bloc.dart';
import '../bloc/unified_mcq_interview_event.dart';
import '../bloc/unified_mcq_interview_state.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_integration_service.dart';
import 'package:mock_interview/core/utils/app_logger.dart';
import 'package:mock_interview/core/di/injection_container.dart';

class McqInterviewSetupView extends StatelessWidget {
  const McqInterviewSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _McqInterviewSetupContent();
  }
}

class _McqInterviewSetupContent extends StatefulWidget {
  const _McqInterviewSetupContent();

  @override
  State<_McqInterviewSetupContent> createState() =>
      _McqInterviewSetupContentState();
}

class _McqInterviewSetupContentState extends State<_McqInterviewSetupContent> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  late final AdIntegrationService _adService;

  String _selectedDifficulty = 'medium';
  String _selectedCategory = 'General';
  int _selectedQuestionCount = 10;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<String> _categories = ['General', 'Technical', 'Behavioral'];
  final List<int> _questionCounts = [5, 10, 15, 20];

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _adService = serviceLocator<AdIntegrationService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<McqInterviewBloc>().add(const StartJobTitleInput());
      } catch (_) {
        final bloc =
            GetIt.instance.isRegistered<McqInterviewBloc>()
                ? GetIt.instance<McqInterviewBloc>()
                : null;
        bloc?.add(const StartJobTitleInput());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'MCQ Interview Setup',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<McqInterviewBloc, UnifiedMcqInterviewState>(
        listener: (context, state) {
          if (state is QuestionsGeneratedState) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        McqInterviewView(
                          questions: state.questions,
                          jobTitle: state.jobTitle,
                        ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else if (state is QuestionGenerationFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<McqInterviewBloc>().add(
                      RetryGeneration(
                        state.jobTitle,
                        difficulty: _selectedDifficulty,
                        category: _selectedCategory,
                        questionCount: _selectedQuestionCount,
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<McqInterviewBloc, UnifiedMcqInterviewState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    _buildCard(
                      'Personal Information',
                      Icons.person_outline,
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jobTitleController,
                            decoration: InputDecoration(
                              labelText: 'Job Title',
                              hintText:
                                  'e.g., Software Engineer, Data Scientist',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a job title';
                              }
                              if (value.trim().length < 3) {
                                return 'Job title must be at least 3 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              context.read<McqInterviewBloc>().add(
                                UpdateJobTitle(value),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Difficulty Level',
                      Icons.trending_up,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children:
                                _difficulties.map((difficulty) {
                                  final isSelected =
                                      _selectedDifficulty == difficulty;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  _selectedDifficulty =
                                                      difficulty,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                            ),
                                          ),
                                          child: Text(
                                            difficulty.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style:
                                                isSelected
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        )
                                                    : Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Interview Category',
                      Icons.category_outlined,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children:
                                _categories.map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => _selectedCategory = category,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          category.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style:
                                              isSelected
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                        color: Colors.white,
                                                      )
                                                  : Theme.of(
                                                    context,
                                                  ).textTheme.labelMedium,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Number of Questions',
                      Icons.quiz_outlined,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children:
                                _questionCounts.map((count) {
                                  final isSelected =
                                      _selectedQuestionCount == count;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  _selectedQuestionCount =
                                                      count,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                            ),
                                          ),
                                          child: Text(
                                            '$count',
                                            textAlign: TextAlign.center,

                                            style:
                                                isSelected
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        )
                                                    : Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Interview Instructions',
                      Icons.info_outline,
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          ...[
                            'Read each question carefully before answering',
                            'Select the best answer from the given options',
                            'You can change your answer before submitting',
                            'Take your time - there\'s no rush',
                            'Review your answers before final submission',
                          ].map(_buildInstructionItem),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildStartButton(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(UnifiedMcqInterviewState state) {
    // Show button for JobTitleInputState and any state that isn't loading/generating
    if (state is JobTitleInputState) {
      return ElevatedButton(
        onPressed: state.isValid ? () => _startInterview(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Start Interview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (state is McqInterviewInitial) {
      // Fallback for initial state - show enabled button
      return ElevatedButton(
        onPressed: () => _startInterview(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Start Interview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (state is GeneratingQuestionsState) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _startInterview(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Show ad before starting interview (user is committed)
      // Pre-interview: track user commitment only (do not show ad here)
      AppLogger.info(
        'McqInterviewSetupView: pre-interview start - tracking only',
      );
      _adService.showBeforeInterviewStart('mcq');

      context.read<McqInterviewBloc>().add(
        GenerateMcqQuestions(
          _jobTitleController.text.trim(),
          difficulty: _selectedDifficulty,
          category: _selectedCategory,
          questionCount: _selectedQuestionCount,
        ),
      );
    }
  }
}

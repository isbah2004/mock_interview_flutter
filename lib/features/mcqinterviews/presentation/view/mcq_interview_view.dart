import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import '../bloc/unified_mcq_interview_bloc.dart';
import '../bloc/unified_mcq_interview_event.dart';
import '../bloc/unified_mcq_interview_state.dart';
import 'mcq_result_view.dart';

class McqInterviewView extends StatelessWidget {
  final List<McqQuestionModel> questions;
  final String jobTitle;

  const McqInterviewView({
    super.key,
    required this.questions,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    return McqInterviewContent(questions: questions, jobTitle: jobTitle);
  }
}

class McqInterviewContent extends StatefulWidget {
  final List<McqQuestionModel> questions;
  final String jobTitle;

  const McqInterviewContent({
    super.key,
    required this.questions,
    required this.jobTitle,
  });

  @override
  State<McqInterviewContent> createState() => _McqInterviewContentState();
}

class _McqInterviewContentState extends State<McqInterviewContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation for loading state
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<McqInterviewBloc>().add(
          StartMcqInterview(widget.questions),
        );
      } catch (_) {
        // Bloc configuration issue handling
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'MCQ Interview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<McqInterviewBloc, UnifiedMcqInterviewState>(
        listener: (context, state) {
          if (state is McqInterviewCompletedState) {
            // Add a small delay to ensure the loading state is visible
            Future.delayed(const Duration(milliseconds: 500), () {
              final results =
                  state.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final userAnswer =
                        index < state.answers.length
                            ? state.answers[index]
                            : '';
                    final isCorrect = userAnswer == question.correctAnswer;

                    return QuestionResultModel(
                      questionId: question.questionId,
                      questionNumber: index + 1,
                      question: question.question,
                      correctAnswer: question.correctAnswer,
                      userAnswer: userAnswer,
                      isCorrect: isCorrect,
                      score: isCorrect ? 1 : 0,
                      explanation: question.explanation,
                      topic: question.topic,
                      difficulty: question.difficulty,
                    );
                  }).toList();

              final evaluationResult = EvaluationResultModel(
                sessionId: state.questions.first.sessionId,
                totalQuestions: state.totalQuestions,
                finalScore: state.score,
                percentage: state.score,
                passed: state.score >= 60.0,
                results: results,
                sessionComplete: true,
                completedAt: DateTime.now(),
              );

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            McqResultView(evaluationResult: evaluationResult),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 300,
                    ),
                  ),
                );
              }
            });
          }
        },
        child: BlocBuilder<McqInterviewBloc, UnifiedMcqInterviewState>(
          builder: (context, state) {
            // Stop pulse animation when not in saving state
            if (state is! SavingInterviewResultState) {
              _pulseController.stop();
            }

            if (state is McqInterviewInProgressState) {
              return _buildInterviewContent(context, state);
            } else if (state is SavingInterviewResultState) {
              return _buildSavingContent(context, state);
            } else if (state is McqInterviewErrorState) {
              return _buildErrorContent(context, state.error);
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInterviewContent(
    BuildContext context,
    McqInterviewInProgressState state,
  ) {
    final currentQuestion = state.currentQuestion;
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.outline.withOpacityCompat(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${state.currentQuestionIndex + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion.question,
                          style: Theme.of(context).textTheme.headlineSmall!,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final optionLabel = String.fromCharCode(65 + index);
                    final isSelected = state.selectedOption == option;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          context.read<McqInterviewBloc>().add(
                            SelectOption(option),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                              width: isSelected ? 2 : 1,
                            ),
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacityCompat(0.1)
                                    : Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.grey.shade300,
                                ),
                                child: Center(
                                  child: Text(
                                    optionLabel,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            fontSize: 15,
                                          )
                                          : Theme.of(
                                            context,
                                          ).textTheme.titleSmall!.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            fontSize: 15,
                                          ),
                                  // style: TextStyle(
                                  //   fontWeight:
                                  //       isSelected
                                  //           ? FontWeight.w600
                                  //           : FontWeight.normal,
                                  //   color:
                                  //       isSelected
                                  //           ? Theme.of(
                                  //             context,
                                  //           ).colorScheme.primary
                                  //           : Colors.black,
                                  //   fontSize: 15,
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              if (state.canNavigatePrevious)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<McqInterviewBloc>().add(
                        const NavigateToPrevious(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Previous',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              if (state.canNavigatePrevious) const SizedBox(width: 16),
              Expanded(
                flex: state.canNavigatePrevious ? 1 : 2,
                child: ElevatedButton(
                  onPressed:
                      state.canNavigateNext
                          ? () {
                            if (state.isLastQuestion) {
                              context.read<McqInterviewBloc>().add(
                                const CompleteInterview(),
                              );
                            } else {
                              context.read<McqInterviewBloc>().add(
                                const NavigateToNext(),
                              );
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    state.isLastQuestion ? 'Submit Interview' : 'Next Question',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingContent(
    BuildContext context,
    SavingInterviewResultState state,
  ) {
    // Start pulse animation when entering saving state
    _pulseController.repeat(reverse: true);

    // percentage not used here; removed to satisfy analyzer

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading indicator with pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 6,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Processing message with fade effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (_pulseAnimation.value * 0.3),
                    child: Text(
                      'Processing Your Results',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Subtext with score info
              Text(
                'Evaluating ${state.questions.length} questions...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacityCompat(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Animated progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final animationValue =
                          (_pulseController.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacityCompat(
                              0.3 + (animationValue * 0.7),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.black, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

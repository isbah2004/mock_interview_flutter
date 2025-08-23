import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview/mcq_interview_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview/mcq_interview_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_result_view.dart';
import '../bloc/mcq_interview/mcq_interview_bloc.dart';
import '../bloc/mcq_navigation/mcq_navigation_bloc.dart';
import '../bloc/mcq_navigation/mcq_navigation_event.dart';
import '../bloc/mcq_navigation/mcq_navigation_state.dart';
import '../cubit/timer_cubit.dart';

class McqInterviewView extends StatelessWidget {
  final String sessionId;
  final List<Question> questions;
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final String category;

  const McqInterviewView({
    super.key,
    required this.sessionId,
    required this.questions,
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  McqNavigationBloc()
                    ..add(InitializeNavigation(questions.length)),
        ),
      ],
      child: McqInterviewContent(
        sessionId: sessionId,
        questions: questions,
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        category: category,
      ),
    );
  }
}

class McqInterviewContent extends StatefulWidget {
  final String sessionId;
  final List<Question> questions;
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final String category;

  const McqInterviewContent({
    super.key,
    required this.sessionId,
    required this.questions,
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });

  @override
  State<McqInterviewContent> createState() => _McqInterviewContentState();
}

class _McqInterviewContentState extends State<McqInterviewContent> {
  @override
  void initState() {
    super.initState();
    // Start timer for 30 minutes (1800 seconds)
    context.read<TimerCubit>().startTimer();
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
          ),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          BlocBuilder<TimerCubit, TimerState>(
            builder: (context, state) {
              if (state.isRunning) {
                final minutes = state.timeRemaining ~/ 60;
                final seconds = state.timeRemaining % 60;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        state.timeRemaining <= 300
                            ? Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1)
                            : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          state.timeRemaining <= 300
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color:
                            state.timeRemaining <= 300
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              state.timeRemaining <= 300
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state.isFinished) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _submitAnswers();
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<McqInterviewBloc, McqInterviewState>(
        listener: (context, state) {
          if (state is InterviewCompleted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        McqResultView(evaluationResult: state.evaluationResult),
              ),
            );
          } else if (state is InterviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<McqNavigationBloc, McqNavigationState>(
          builder: (context, navigationState) {
            if (navigationState is! McqNavigationReady) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentQuestion =
                widget.questions[navigationState.currentQuestionIndex];

            return Column(
              children: [
                // Progress Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${navigationState.currentQuestionIndex + 1} of ${widget.questions.length}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${((navigationState.currentQuestionIndex + 1) / widget.questions.length * 100).round()}%',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            (navigationState.currentQuestionIndex + 1) /
                            widget.questions.length,
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),

                // Question Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentQuestion.category.toUpperCase(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentQuestion.questionText,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Options
                        ...currentQuestion.options!.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final option = entry.value;
                          return _buildOptionCard(
                            option,
                            String.fromCharCode(65 + index),
                            navigationState.selectedOption,
                            context,
                          );
                        }),

                        const SizedBox(
                          height: 100,
                        ), // Space for navigation buttons
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (navigationState.currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<McqNavigationBloc>().add(
                                  NavigateToPrevious(),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Previous',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Spacer(),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  navigationState.selectedOption != null
                                      ? () {
                                        if (navigationState
                                                .currentQuestionIndex ==
                                            widget.questions.length - 1) {
                                          _submitAnswers();
                                        } else {
                                          context.read<McqNavigationBloc>().add(
                                            NavigateToNext(),
                                          );
                                        }
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    navigationState.currentQuestionIndex ==
                                            widget.questions.length - 1
                                        ? 'Submit'
                                        : 'Next',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    navigationState.currentQuestionIndex ==
                                            widget.questions.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward_ios,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    String option,
    String label,
    String? selectedAnswer,
    BuildContext context,
  ) {
    final isSelected = selectedAnswer == option;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          context.read<McqNavigationBloc>().add(SelectOption(option));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    )
                    : null,
            color: isSelected ? null : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnswers() {
    final navigationState = context.read<McqNavigationBloc>().state;
    if (navigationState is McqNavigationReady) {
      context.read<McqInterviewBloc>().add(
        SubmitAnswersEvent(
          sessionId: widget.sessionId,
          userId: widget.userId,
          answers: navigationState.answers,
          jobRole: widget.jobRole,
          difficultyLevel: widget.difficultyLevel,
          category: widget.category,
        ),
      );
    }
  }
}

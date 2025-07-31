import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'dart:async';

import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_bloc.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_event.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_state.dart';
class MCQInterviewScreen extends StatefulWidget {
  final String jobRole;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final int numberOfQuestions;
  final int timePerQuestion;

  const MCQInterviewScreen({
    super.key,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.numberOfQuestions,
    required this.timePerQuestion,
  });

  @override
  State<MCQInterviewScreen> createState() => _MCQInterviewScreenState();
}

class _MCQInterviewScreenState extends State<MCQInterviewScreen>
    with TickerProviderStateMixin {
  int? selectedAnswer;
  Timer? questionTimer;
  late AnimationController _progressController;
  late int timeRemaining;

  @override
  void initState() {
    super.initState();
    timeRemaining = widget.timePerQuestion;
    _progressController = AnimationController(
      duration: Duration(seconds: widget.timePerQuestion),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = '6887d7e32412bb6bcbdd';
      context.read<McqInterviewBloc>().add(
        StartMcqInterviewEvent(
          userId: userId,
          jobRole: widget.jobRole,
          difficultyLevel: widget.difficulty,
          category: widget.category,
          numQuestions: widget.numberOfQuestions,
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    questionTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer(VoidCallback onTimeout) {
    timeRemaining = widget.timePerQuestion;
    _progressController.reset();
    _progressController.forward();

    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
      });

      if (timeRemaining <= 0) {
        timer.cancel();
        onTimeout();
      }
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit Interview?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: const Text(
            'Are you sure you want to exit? Your progress will be lost.',
            style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continue',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<McqInterviewBloc, McqInterviewState>(
      listener: (context, state) {
        if (state is McqInterviewStarted) {
          _startQuestionTimer(() {
            // Auto-submit empty answer if time runs out
            context.read<McqInterviewBloc>().add(
              SubmitMcqAnswerEvent(
                sessionId: state.sessionId,
                answer: '',
                userId: ID.unique(),
                jobRole: widget.jobRole,
              ),
            );
          });
          setState(() {
            selectedAnswer = null;
            timeRemaining = widget.timePerQuestion;
          });
        }
        if (state is McqInterviewFeedback) {
          questionTimer?.cancel();
        }
        if (state is McqInterviewCompleted) {
          questionTimer?.cancel();
          // Navigate to results or show dialog
          Navigator.pushReplacementNamed(context, '/interview-results');
        }
      },
      builder: (context, state) {
        if (state is McqInterviewLoading || state is McqInterviewInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is McqInterviewError) {
          return Center(child: Text(state.message));
        }
        if (state is McqInterviewStarted) {
          final question = state.currentQuestion;
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF9FAFB), Colors.white, Color(0xFFF3F4F6)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _showExitDialog(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF374151),
                                    size: 20,
                                  ),
                                ),
                              ),
                              Text(
                                'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      timeRemaining <= 10
                                          ? const LinearGradient(
                                            colors: [
                                              Colors.red,
                                              Color(0xFFDC2626),
                                            ],
                                          )
                                          : const LinearGradient(
                                            colors: [
                                              Color(0xFF374151),
                                              Color(0xFF4B5563),
                                            ],
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${timeRemaining}s',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 1 - _progressController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            timeRemaining <= 10
                                                ? [
                                                  Colors.red,
                                                  Color(0xFFDC2626),
                                                ]
                                                : [
                                                  Color(0xFF374151),
                                                  Color(0xFF4B5563),
                                                ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Question Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF374151),
                                              Color(0xFF4B5563),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.quiz,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Question',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    question.questionText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Answer Options
                            Expanded(
                              child: ListView.builder(
                                itemCount: question.options?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final isSelected = selectedAnswer == index;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAnswer = index;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF111827)
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF111827)
                                                    : const Color(0xFFE5E7EB),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                          0xFFF3F4F6,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : const Color(
                                                            0xFFD1D5DB,
                                                          ),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  String.fromCharCode(
                                                    65 + index,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        isSelected
                                                            ? const Color(
                                                              0xFF111827,
                                                            )
                                                            : const Color(
                                                              0xFF6B7280,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                question.options![index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : const Color(
                                                            0xFF111827,
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Next Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              margin: const EdgeInsets.only(bottom: 24),
                              child: ElevatedButton(
                                onPressed:
                                    selectedAnswer != null
                                        ? () {
                                          context.read<McqInterviewBloc>().add(
                                            SubmitMcqAnswerEvent(
                                              sessionId: state.sessionId,
                                              answer:
                                                  question
                                                      .options![selectedAnswer!],
                                              userId:
                                                  ID.unique(),
                                              jobRole: widget.jobRole,
                                            ),
                                          );
                                        }
                                        : null,
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
                                    gradient: LinearGradient(
                                      colors:
                                          selectedAnswer != null
                                              ? [
                                                Color(0xFF374151),
                                                Color(0xFF4B5563),
                                              ]
                                              : [
                                                Color(0xFF9CA3AF),
                                                Color(0xFF6B7280),
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
                                  child: Center(
                                    child: Text(
                                      state.currentQuestionIndex <
                                              state.totalQuestions - 1
                                          ? 'Next Question'
                                          : 'Finish Interview',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is McqInterviewFeedback) {
          // Show feedback and next/finish button
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.feedback,
                    style: TextStyle(
                      fontSize: 20,
                      color: state.isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (state.isLastQuestion) {
                        context.read<McqInterviewBloc>().add(
                          const CompleteInterviewEvent(),
                        );
                      } else {
                        context.read<McqInterviewBloc>().add(
                          const ProceedToNextQuestionEvent(),
                        );
                      }
                    },
                    child: Text(state.isLastQuestion ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is McqInterviewCompleted) {
          return Scaffold(
            body: Center(
              child: Text(
                'Interview Completed!\nScore: ${state.finalScore.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

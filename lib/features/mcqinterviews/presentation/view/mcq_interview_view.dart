import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/result_view.dart';
import '../bloc/mcq_interview_bloc.dart';
import '../cubit/timer_cubit.dart';

class McqInterviewPage extends StatefulWidget {
  final String sessionId;
  final List<Question> questions;

  const McqInterviewPage({
    super.key,
    required this.sessionId,
    required this.questions,
  });

  @override
  State<McqInterviewPage> createState() => _McqInterviewPageState();
}

class _McqInterviewPageState extends State<McqInterviewPage> {
  int _currentQuestionIndex = 0;
  List<String> _answers = [];
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.questions.length, '');
    // Start timer for 30 minutes (1800 seconds)
    context.read<TimerCubit>().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Interview in Progress',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        actions: [
          BlocBuilder<TimerCubit, TimerState>(
            builder: (context, timerState) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      timerState.timeRemaining < 300
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        timerState.timeRemaining < 300
                            ? Colors.red.shade300
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color:
                          timerState.timeRemaining < 300
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.read<TimerCubit>().formattedTime,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            timerState.timeRemaining < 300
                                ? Colors.red.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<McqInterviewBloc, McqInterviewState>(
            listener: (context, state) {
              if (state is InterviewCompleted) {
                context.read<TimerCubit>().stopTimer();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => ResultPage(
                          evaluationResult: state.evaluationResult,
                        ),
                  ),
                );
              } else if (state is InterviewError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<TimerCubit, TimerState>(
            listener: (context, timerState) {
              if (timerState.isFinished) {
                _submitAnswers();
              }
            },
          ),
        ],
        child: BlocBuilder<McqInterviewBloc, McqInterviewState>(
          builder: (context, state) {
            if (state is InterviewLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            final currentQuestion = widget.questions[_currentQuestionIndex];

            return Column(
              children: [
                // Progress Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          Text(
                            '${((_currentQuestionIndex + 1) / widget.questions.length * 100).round()}%',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            (_currentQuestionIndex + 1) /
                            widget.questions.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Question Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            currentQuestion.questionText,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.black),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Options
                        ...List.generate(
                          currentQuestion.options!.length,
                          (index) => _buildOptionCard(
                            index,
                            currentQuestion.options![index],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousQuestion,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Previous',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.black),
                            ),
                          ),
                        ),

                      if (_currentQuestionIndex > 0) const SizedBox(width: 16),

                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              _selectedOption != null ? _nextQuestion : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _currentQuestionIndex == widget.questions.length - 1
                                ? 'Submit Interview'
                                : 'Next Question',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, String option) {
    final isSelected = _selectedOption == option;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOption = option;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOption =
            _answers[_currentQuestionIndex].isNotEmpty
                ? _answers[_currentQuestionIndex]
                : null;
      });
    }
  }

  void _nextQuestion() {
    if (_selectedOption != null) {
      _answers[_currentQuestionIndex] = _selectedOption.toString();

      if (_currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption =
              _answers[_currentQuestionIndex].isNotEmpty
                  ? _answers[_currentQuestionIndex]
                  : null;
        });
      } else {
        _submitAnswers();
      }
    }
  }

  void _submitAnswers() {
    if (_selectedOption != null) {
      _answers[_currentQuestionIndex] = _selectedOption.toString();
    }

    context.read<McqInterviewBloc>().add(
      SubmitAnswersEvent(
        sessionId: widget.sessionId,
        userId: 'user_123', // Mock user ID
        answers: _answers,
        jobRole: '',
        difficultyLevel: 'easy',
        category: 'technical',
      ),
    );
  }
}

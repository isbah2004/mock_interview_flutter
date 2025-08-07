import 'package:flutter/material.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/core/entities/question_result.dart';

class InterviewResultScreen extends StatefulWidget {
  final EvaluationResult evaluationResult;

  const InterviewResultScreen({super.key, required this.evaluationResult});

  @override
  State<InterviewResultScreen> createState() => _InterviewResultScreenState();
}

class _InterviewResultScreenState extends State<InterviewResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 20),
                const Text(
                  'Interview Results',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Score Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Circular Score Display
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _scoreController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value:
                                    _scoreController.value *
                                    (widget.evaluationResult.percentage / 100),
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(
                                    widget.evaluationResult.percentage,
                                  ),
                                ),
                                semanticsLabel: 'Score progress',
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Score Percentage
                        Text(
                          '${widget.evaluationResult.percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(
                              widget.evaluationResult.percentage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Performance Label
                        Text(
                          _getPerformanceLabel(
                            widget.evaluationResult.percentage,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(
                              widget.evaluationResult.percentage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statistics Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              context,
                              'Questions',
                              '${widget.evaluationResult.totalQuestions}',
                              Colors.blue,
                            ),
                            _buildStatItem(
                              context,
                              'Correct',
                              '${widget.evaluationResult.results.where((r) => r.isCorrect).length}',
                              Colors.green,
                            ),
                            _buildStatItem(
                              context,
                              'Score',
                              '${widget.evaluationResult.finalScore.toInt()}',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pass/Fail Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        widget.evaluationResult.passed
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          widget.evaluationResult.passed
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.evaluationResult.passed
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            widget.evaluationResult.passed
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.evaluationResult.passed
                            ? 'Congratulations! You passed the interview.'
                            : 'You didn\'t pass this time. Keep practicing!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.evaluationResult.passed
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Question Results
                const Text(
                  'Question by Question Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),

                // Question Results List
                ...widget.evaluationResult.results.map(
                  (result) => _buildQuestionResultCard(context, result),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _startNewInterview(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _goHome(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuestionResultCard(
    BuildContext context,
    QuestionResult questionResult,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        questionResult.isCorrect
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    questionResult.isCorrect ? 'CORRECT' : 'INCORRECT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          questionResult.isCorrect
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Q${questionResult.questionId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              questionResult.question,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildAnswerRow(
              context,
              'Your Answer:',
              questionResult.userAnswer,
              questionResult.isCorrect ? Colors.green : Colors.red,
            ),
            if (!questionResult.isCorrect) ...[
              const SizedBox(height: 4),
              _buildAnswerRow(
                context,
                'Correct Answer:',
                questionResult.correctAnswer,
                Colors.green,
              ),
            ],
            if (questionResult.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      questionResult.explanation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context,
    String label,
    String answer,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getPerformanceLabel(double percentage) {
    if (percentage >= 90) {
      return 'Excellent';
    } else if (percentage >= 80) {
      return 'Good';
    } else if (percentage >= 60) {
      return 'Average';
    } else {
      return 'Needs Improvement';
    }
  }

  void _startNewInterview(BuildContext context) {
    // Navigate back to interview setup
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goHome(BuildContext context) {
    // Navigate to home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

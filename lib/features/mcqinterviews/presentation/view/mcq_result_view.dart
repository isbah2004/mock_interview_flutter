import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_integration_service.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

class McqResultView extends StatefulWidget {
  final EvaluationResultModel evaluationResult;

  const McqResultView({super.key, required this.evaluationResult});

  @override
  State<McqResultView> createState() => _McqResultViewState();
}

class _McqResultViewState extends State<McqResultView> {
  late final AdIntegrationService _adService;

  @override
  void initState() {
    super.initState();
    _adService = serviceLocator<AdIntegrationService>();

    // Show ad after interview completion (natural pause point)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.info('McqResultView: requesting post-interview ad for mcq');
      _adService.showAfterInterviewCompletion('mcq');
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = widget.evaluationResult.passed;
    final double percentage = widget.evaluationResult.percentage;
    final int totalQuestions = widget.evaluationResult.totalQuestions;
    final List<QuestionResultModel> results =
        widget.evaluationResult.results.cast<QuestionResultModel>();
    final int correctAnswers = results.where((r) => r.isCorrect).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Interview Results',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacityCompat(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: passed ? Colors.green.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed ? Icons.check_circle : Icons.cancel,
                      size: 40,
                      color: passed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${percentage.round()}%',
                    style: TextStyle(
                      fontSize: 48,
                      color: passed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed
                        ? 'Congratulations! You Passed'
                        : 'Better Luck Next Time',
                    style: TextStyle(
                      fontSize: 20,
                      color: passed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacityCompat(0.3),
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacityCompat(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$correctAnswers out of $totalQuestions questions correct',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildDetailedScoreCard(
              context,
              results,
              percentage,
              correctAnswers,
              totalQuestions,
            ),

            const SizedBox(height: 24),

            _buildTopicSummary(context, results),

            const SizedBox(height: 24),

            Text(
              'Question Review',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuestionList(context, results),

            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: () {
            //           // Track retry interaction and show ad strategically (tracking only)
            //           AppLogger.info(
            //             'McqResultView: Try Again tapped - tracking interview retry',
            //           );
            //           _adService.showOnInterviewRetry();

            //           Navigator.of(context).pushAndRemoveUntil(
            //             MaterialPageRoute(
            //               builder: (context) => const McqInterviewSetupView(),
            //             ),
            //             (route) => false,
            //           );
            //         },
            //         style: OutlinedButton.styleFrom(
            //           side: BorderSide(color: Colors.grey.shade400),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //         ),
            //         child: Text(
            //           'Try Again',
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           // Track new interview interaction
            //           _adService.trackInteraction('new_interview_request');

            //           Navigator.of(context).pushAndRemoveUntil(
            //             MaterialPageRoute(
            //               builder: (context) => const McqInterviewSetupView(),
            //             ),
            //             (route) => false,
            //           );
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Theme.of(context).colorScheme.primary,
            //           foregroundColor: Colors.white,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //           elevation: 0,
            //         ),
            //         child: Text(
            //           'New Interview',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedScoreCard(
    BuildContext context,
    List<QuestionResultModel> results,
    double percentage,
    int correctAnswers,
    int totalQuestions,
  ) {
    final difficulty = results.isNotEmpty ? results.first.difficulty : "Medium";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacityCompat(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Breakdown',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'Performance analysis',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildScoreMetric(
                  context,
                  'Final Score',
                  '${percentage.round()}%',
                  Icons.emoji_events,
                  _getAccuracyColor(percentage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreMetric(
                  context,
                  'Accuracy',
                  '$correctAnswers/$totalQuestions',
                  Icons.gps_fixed,
                  _getAccuracyColor(percentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreMetric(
                  context,
                  'Difficulty',
                  difficulty.toUpperCase(),
                  Icons.trending_up,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreMetric(
                  context,
                  'Status',
                  percentage >= 60 ? 'PASSED' : 'FAILED',
                  percentage >= 60 ? Icons.check_circle : Icons.cancel,
                  percentage >= 60 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSummary(
    BuildContext context,
    List<QuestionResultModel> results,
  ) {
    Map<String, List<QuestionResultModel>> topicGroups = {};
    for (var result in results) {
      String topic = result.topic;
      topicGroups[topic] = topicGroups[topic] ?? [];
      topicGroups[topic]!.add(result);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacityCompat(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance by Topic',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...topicGroups.entries.map((entry) {
            int correct = entry.value.where((r) => r.isCorrect).length;
            int total = entry.value.length;
            double percentage = (correct / total) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _getAccuracyColor(percentage).withOpacityCompat(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getAccuracyColor(percentage).withOpacityCompat(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${percentage.round()}% accuracy',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getAccuracyColor(percentage),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$correct/$total',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionList(
    BuildContext context,
    List<QuestionResultModel> results,
  ) {
    return Column(
      children:
          results.map((result) {
            bool isCorrect = result.isCorrect;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isCorrect
                          ? Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacityCompat(0.5)
                          : Theme.of(
                            context,
                          ).colorScheme.error.withOpacityCompat(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              isCorrect
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Question ${result.questionNumber}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    result.question,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 12),

                  if (!isCorrect) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Answer:',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.userAnswer.isEmpty
                                ? 'Not Answered'
                                : result.userAnswer,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Answer:',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.correctAnswer,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (result.explanation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacityCompat(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacityCompat(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Explanation',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.explanation,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildScoreMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacityCompat(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacityCompat(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade600;
    if (percentage >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import '../../domain/entities/interview_config.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/interview_message.dart';
import '../../utils/ai_response_cleaner.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/voice_interview_evaluation_result.dart';
import '../../../../core/models/voice_evaluation_model.dart';
import '../../../../core/services/unified_database_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../ads/presentation/services/ad_integration_service.dart';

class InterviewResultView extends StatelessWidget {
  final InterviewSession session;
  final InterviewConfig config;
  final VoiceEvaluationModel? existingEvaluation;

  const InterviewResultView({
    super.key,
    required this.session,
    required this.config,
    this.existingEvaluation,
  });

  @override
  Widget build(BuildContext context) {
    return _InterviewResultViewContent(
      session: session,
      config: config,
      existingEvaluation: existingEvaluation,
    );
  }
}

class _InterviewResultViewContent extends StatelessWidget {
  final InterviewSession session;
  final InterviewConfig config;
  final VoiceEvaluationModel? existingEvaluation;

  const _InterviewResultViewContent({
    required this.session,
    required this.config,
    this.existingEvaluation,
  });

  @override
  Widget build(BuildContext context) {
    // Show ad after voice interview completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adService = di.serviceLocator<AdIntegrationService>();
      adService.showAfterInterviewCompletion('voice');
    });

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
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          existingEvaluation != null
              ? _buildResultsFromEvaluation(existingEvaluation!, context)
              : _buildEvaluationNotAvailable(context),
    );
  }

  Widget _buildEvaluationNotAvailable(BuildContext context) {
    // If we don't have existing evaluation data, show an appropriate message
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Evaluation Not Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The detailed evaluation for this interview is not available. This might be because the interview was not properly completed or the evaluation data was not saved.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (session.messages.isNotEmpty) ...[
              Text(
                'However, you can still view the conversation:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: _buildConversationDisplay(context)),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: () {
                // Track navigation back to history and show ad strategically
                final adService = di.serviceLocator<AdIntegrationService>();
                adService.showOnMenuNavigation();

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text('Back to History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationDisplayWithMessages(
    List<InterviewMessage> messages,
    BuildContext context,
  ) {
    // First, let's see the original order
    AppLogger.debug('=== ORIGINAL MESSAGE ORDER ===');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      AppLogger.debug(
        'Original $i: ${msg.type} - ${msg.timestamp} - ${msg.content.substring(0, msg.content.length > 30 ? 30 : msg.content.length)}...',
      );
    }

    // Sort messages by timestamp to ensure correct chronological order
    final sortedMessages = List<InterviewMessage>.from(messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Debug: Print sorted message order
    AppLogger.debug('=== SORTED MESSAGE ORDER ===');
    for (int i = 0; i < sortedMessages.length; i++) {
      final msg = sortedMessages[i];
      AppLogger.debug(
        'Sorted $i: ${msg.type} - ${msg.timestamp} - ${msg.content.substring(0, msg.content.length > 30 ? 30 : msg.content.length)}...',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(76),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Interview Conversation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                reverse: false, // Start from the beginning of conversation
                itemCount: sortedMessages.length,
                itemBuilder: (context, index) {
                  final message = sortedMessages[index];
                  final isUser = message.type == MessageType.user;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                !isUser
                                    ? [
                                      AppColors.primaryPurple,
                                      AppColors.primaryPurpleDark,
                                    ]
                                    : [
                                      Theme.of(context).colorScheme.outline,
                                      Theme.of(context).colorScheme.outline,
                                    ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isUser ? 20 : 6),
                            bottomRight: Radius.circular(isUser ? 6 : 20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        !isUser
                                            ? Colors.white.withAlpha(20)
                                            : AppColors.primaryPurple
                                                .withOpacityCompat(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isUser ? Icons.person : Icons.smart_toy,
                                    size: 14,
                                    color:
                                        !isUser
                                            ? Colors.white
                                            : AppColors.primaryPurple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isUser ? 'You' : 'AI Interviewer',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    color:
                                        !isUser
                                            ? Colors.white.withOpacityCompat(
                                              0.9,
                                            )
                                            : AppColors.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message.content,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color:
                                    isUser
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onSurface
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
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
          ),
        ],
      ),
    );
  }

  Widget _buildConversationDisplay(BuildContext context) {
    // Use session messages for live interview view
    return _buildConversationDisplayWithMessages(session.messages, context);
  }

  MessageType _parseMessageType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'user':
        return MessageType.user;
      case 'ai':
        return MessageType.ai;
      case 'system':
        return MessageType.system;
      case 'error':
        return MessageType.error;
      default:
        return MessageType.ai;
    }
  }

  Widget _buildResultsFromEvaluation(
    VoiceEvaluationModel evaluation,
    BuildContext context,
  ) {
    // Since conversationMessages are now stored separately, we need to fetch them
    return FutureBuilder<List<InterviewMessage>>(
      future: _fetchConversationMessages(evaluation.sessionId),
      builder: (context, snapshot) {
        List<InterviewMessage> conversationMessages = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading state while fetching messages
          conversationMessages = []; // Empty for now, will show loading
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          conversationMessages = snapshot.data!;
          AppLogger.info(
            'InterviewResultView: Using fetched messages (${conversationMessages.length})',
          );
        } else {
          // Fallback 1: try to get messages from evaluation if still available
          if (evaluation.conversationMessages.isNotEmpty) {
            conversationMessages =
                evaluation.conversationMessages.map((msgData) {
                  return InterviewMessage(
                    content: msgData['content'] ?? '',
                    type: _parseMessageType(msgData['type'] ?? 'ai'),
                    timestamp:
                        DateTime.tryParse(msgData['timestamp'] ?? '') ??
                        DateTime.now(),
                  );
                }).toList();
            AppLogger.info(
              'InterviewResultView: Using evaluation messages (${conversationMessages.length})',
            );
          }
          // Fallback 2: use session messages if available
          else if (session.messages.isNotEmpty) {
            conversationMessages = session.messages;
            AppLogger.info(
              'InterviewResultView: Using session messages (${conversationMessages.length})',
            );
          } else {
            AppLogger.warn(
              'InterviewResultView: No conversation messages found from any source',
            );
          }
        }

        // Convert VoiceEvaluationModel to VoiceInterviewEvaluationResult format for display
        final evaluationResult = VoiceInterviewEvaluationResult(
          sessionId: evaluation.sessionId,
          totalQuestions: evaluation.totalQuestions,
          results: [], // Empty for historical view
          finalScore: evaluation.finalScore,
          percentage: evaluation.percentage,
          passed: evaluation.passed,
          sessionComplete: evaluation.sessionComplete,
          completedAt: evaluation.completedAt,
          feedback: evaluation.feedback,
          aiCorrectAnswers: evaluation.aiCorrectAnswers,
          communicationScore: evaluation.communicationScore,
          contentScore: evaluation.contentScore,
          overallScore: evaluation.overallScore,
        );

        return _buildResultsViewWithMessages(
          evaluationResult,
          conversationMessages,
          context,
        );
      },
    );
  }

  // Add method to fetch conversation messages from voice_messages collection
  Future<List<InterviewMessage>> _fetchConversationMessages(
    String sessionId,
  ) async {
    try {
      AppLogger.info(
        'InterviewResultView: Fetching conversation messages for sessionId: $sessionId',
      );

      // Get the database service from dependency injection
      final databaseService = di.serviceLocator<UnifiedDatabaseService>();
      final voiceMessages = await databaseService.getVoiceMessages(sessionId);

      AppLogger.info(
        'InterviewResultView: Found ${voiceMessages.length} voice messages',
      );

      // Convert VoiceMessageModel to InterviewMessage
      final messages =
          voiceMessages
              .map(
                (voiceMsg) => InterviewMessage(
                  content: voiceMsg.content ?? '', // Handle nullable content
                  type: _parseMessageType(voiceMsg.messageType),
                  timestamp: voiceMsg.timestamp,
                ),
              )
              .toList();

      AppLogger.info(
        'InterviewResultView: Converted to ${messages.length} interview messages',
      );
      return messages;
    } catch (e) {
      AppLogger.error(
        'InterviewResultView: Failed to fetch conversation messages: $e',
      );
      return [];
    }
  }

  Widget _buildResultsViewWithMessages(
    dynamic evaluationResult,
    List<InterviewMessage> messages,
    BuildContext context,
  ) {
    final double overallScore = evaluationResult.overallScore ?? 0.0;
    final double communicationScore =
        evaluationResult.communicationScore ?? 0.0;
    final double contentScore = evaluationResult.contentScore ?? 0.0;
    final bool passed = overallScore >= 6.0;
    final double percentage = (overallScore / 10.0) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Score Card
          _buildMainScoreCard(passed, percentage, overallScore, context),

          const SizedBox(height: 24),

          // Detailed Score Breakdown
          _buildDetailedScoreCard(
            overallScore,
            communicationScore,
            contentScore,
            config,
            context,
          ),

          const SizedBox(height: 24),

          // AI Feedback Section
          _buildFeedbackSection(evaluationResult.feedback ?? '', context),

          const SizedBox(height: 24),

          // Interview Conversation
          if (messages.isNotEmpty) ...[
            _buildConversationDisplayWithMessages(messages, context),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          _buildActionButtons(context),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMainScoreCard(
    bool passed,
    double percentage,
    double overallScore,
    BuildContext context,
  ) {
    return Container(
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
            passed ? 'Great Performance!' : 'Keep Practicing!',
            style: TextStyle(
              fontSize: 20,
              color: passed ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacityCompat(0.3),
              ),
              color: Theme.of(context).colorScheme.primary.withOpacityCompat(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Overall Score: ${overallScore.toStringAsFixed(1)}/10',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScoreCard(
    double overallScore,
    double communicationScore,
    double contentScore,
    InterviewConfig config,
    BuildContext context,
  ) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Analysis',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'AI-powered assessment',
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
                  'Overall Score',
                  '${overallScore.toStringAsFixed(1)}/10',
                  Icons.emoji_events,
                  _getScoreColor(overallScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreMetric(
                  'Communication',
                  '${communicationScore.toStringAsFixed(1)}/10',
                  Icons.record_voice_over,
                  _getScoreColor(communicationScore),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreMetric(
                  'Content Quality',
                  '${contentScore.toStringAsFixed(1)}/10',
                  Icons.lightbulb,
                  _getScoreColor(contentScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreMetric(
                  'Difficulty',
                  config.difficulty.displayName.toUpperCase(),
                  Icons.trending_up,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMetric(
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

  Widget _buildFeedbackSection(String feedback, BuildContext context) {
    final cleanedFeedback = AIResponseCleaner.cleanAIResponse(feedback);

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.feedback_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Feedback & Recommendations',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacityCompat(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacityCompat(0.3),
              ),
            ),
            child: Text(
              cleanedFeedback.isNotEmpty
                  ? cleanedFeedback
                  : 'No feedback available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green.shade600;
    if (score >= 6.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

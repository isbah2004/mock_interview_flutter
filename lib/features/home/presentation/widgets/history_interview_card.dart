import 'package:flutter/material.dart';
import 'package:mock_interview/features/home/data/models/interview_history_model.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_result_view.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/interview_result_view.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/core/models/mcq_evaluation_model.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/models/voice_message_model.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart'
    as voice;
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart'
    as voice;
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart'
    as voice;
import 'package:mock_interview/core/di/injection_container.dart' as di;
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_integration_service.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

class HistoryInterviewCard extends StatefulWidget {
  final InterviewHistoryModel interview;

  const HistoryInterviewCard({super.key, required this.interview});

  @override
  State<HistoryInterviewCard> createState() => _HistoryInterviewCardState();
}

class _HistoryInterviewCardState extends State<HistoryInterviewCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (widget.interview.isComplete == true) {
                _navigateToResults(context);
              } else {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _MinimalIconContainer(icon: widget.interview.icon),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (() {
                                final s =
                                    widget.interview.type
                                        .toString()
                                        .split('.')
                                        .last;
                                return s.isEmpty
                                    ? ''
                                    : '${s[0].toUpperCase()}${s.substring(1)}';
                              })(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            // const SizedBox(height: 2),
                            Text(
                              (() {
                                final s = widget.interview.jobRole;
                                return s.isEmpty
                                    ? ''
                                    : '${s[0].toUpperCase()}${s.substring(1)}';
                              })(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacityCompat(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MinimalScore(score: widget.interview.score ?? 0),
                      if (widget.interview.isComplete != true) ...[
                        const SizedBox(width: 12),
                        Icon(
                          isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: theme.colorScheme.onSurface.withOpacityCompat(
                            0.5,
                          ),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMinimalChip(widget.interview.category, theme),
                      const SizedBox(width: 8),
                      _buildMinimalChip(
                        widget.interview.difficulty.toString().split('.').last,
                        theme,
                      ),
                      const Spacer(),
                      _buildMinimalInfo(
                        Icons.schedule_rounded,
                        widget.interview.duration,
                        theme,
                      ),
                    ],
                  ),
                  if (widget.interview.isComplete == true) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap to view results',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded) _buildMinimalExpandedContent(theme),
        ],
      ),
    );
  }

  Widget _buildMinimalExpandedContent(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacityCompat(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMinimalDetailItem(
                  'Questions',
                  '${widget.interview.totalQuestions ?? 'N/A'}',
                  theme,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMinimalDetailItem(
                  'Final Score',
                  widget.interview.finalScore?.toStringAsFixed(1) ?? 'N/A',
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMinimalDetailItem(
                  'Status',
                  widget.interview.status.name,
                  theme,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMinimalDetailItem(
                  'Result',
                  widget.interview.passed == true
                      ? 'Passed'
                      : 'Needs Improvement',
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalDetailItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacityCompat(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _navigateToResults(BuildContext context) async {
    // Track results viewing interaction and show ad strategically
    final adService = di.serviceLocator<AdIntegrationService>();
    AppLogger.info(
      'HistoryInterviewCard: recording results viewed (tracking only)',
    );
    adService.showOnResultsViewing();

    // Check if we have detailed result data available first
    if (widget.interview.mcqResult != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  McqResultView(evaluationResult: widget.interview.mcqResult!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (widget.interview.voiceSession != null &&
        widget.interview.voiceConfig != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => InterviewResultView(
                session: widget.interview.voiceSession!,
                config: widget.interview.voiceConfig!,
                existingEvaluation:
                    null, // This case already has embedded results
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (widget.interview.sessionData != null) {
      // For cases where we only have session data, fetch detailed data from database
      final sessionData = widget.interview.sessionData!;

      if (sessionData.interviewType == 'mcq') {
        await _navigateToMcqResultWithDetailedData(context, sessionData);
      } else if (sessionData.interviewType == 'voice') {
        await _navigateToVoiceResultWithDetailedData(context, sessionData);
      } else {
        // For voice interviews without full data, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice interview details require full session data'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Fallback - show a message that details aren't available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interview details not available for viewing'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToMcqResultWithDetailedData(
    BuildContext context,
    UnifiedInterviewSession sessionData,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final databaseService = di.serviceLocator<UnifiedDatabaseService>();

      // Fetch detailed data
      final questions = await databaseService.getMcqQuestions(
        sessionData.sessionId,
      );
      final evaluation = await databaseService.getMcqEvaluation(
        sessionData.sessionId,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (questions.isNotEmpty) {
        // Create detailed evaluation result with questions and answers
        final detailedResult = _createDetailedMcqResult(
          sessionData,
          questions,
          evaluation,
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    McqResultView(evaluationResult: detailedResult),
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
      } else {
        // Fallback to basic result if no detailed data available
        await _navigateToBasicMcqResult(context, sessionData);
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load interview details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToVoiceResultWithDetailedData(
    BuildContext context,
    UnifiedInterviewSession sessionData,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final databaseService = di.serviceLocator<UnifiedDatabaseService>();

      // Fetch detailed voice data
      final messages = await databaseService.getVoiceMessages(
        sessionData.sessionId,
      );
      final evaluation = await databaseService.getVoiceEvaluation(
        sessionData.sessionId,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      // Always try to navigate to show results
      // Create InterviewConfig from session data
      final config = _createInterviewConfigFromSession(sessionData);

      // Create InterviewSession from messages and evaluation
      final session = _createInterviewSessionFromData(
        config,
        messages,
        evaluation,
        sessionData,
      );

      // Navigate to InterviewResultView with existing evaluation (even if null)
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => InterviewResultView(
                session: session,
                config: config,
                existingEvaluation: evaluation, // Pass evaluation even if null
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load voice interview details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToBasicMcqResult(
    BuildContext context,
    UnifiedInterviewSession sessionData,
  ) async {
    // Create a basic result object for MCQ with empty results
    final basicResult = EvaluationResultModel(
      sessionId: sessionData.sessionId,
      totalQuestions: sessionData.totalQuestions,
      results: const [], // Empty list since we don't have question details
      finalScore: sessionData.score ?? 0.0,
      percentage: sessionData.percentage ?? 0.0,
      passed: sessionData.passed ?? false,
      sessionComplete: sessionData.isCompleted,
      completedAt: sessionData.completedAt ?? DateTime.now(),
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                McqResultView(evaluationResult: basicResult),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  EvaluationResultModel _createDetailedMcqResult(
    UnifiedInterviewSession sessionData,
    List<McqQuestionModel> questions,
    McqEvaluationModel? evaluation,
  ) {
    // Convert MCQ questions to QuestionResultModel
    final results =
        questions.map((question) {
          return QuestionResultModel(
            questionId: question.questionId,
            questionNumber: question.questionNo,
            question: question.question,
            userAnswer: question.userAnswer ?? 'Not Answered',
            correctAnswer: question.correctAnswer,
            isCorrect: question.isCorrect ?? false,
            score: question.score?.toInt() ?? 0,
            explanation: question.explanation,
            topic: question.topic,
            difficulty: question.difficulty,
          );
        }).toList();

    return EvaluationResultModel(
      sessionId: sessionData.sessionId,
      totalQuestions: sessionData.totalQuestions,
      results: results,
      finalScore: evaluation?.finalScore ?? sessionData.score ?? 0.0,
      percentage: sessionData.percentage ?? 0.0,
      passed: sessionData.passed ?? false,
      sessionComplete: sessionData.isCompleted,
      completedAt: sessionData.completedAt ?? DateTime.now(),
    );
  }
}

class _MinimalIconContainer extends StatelessWidget {
  final IconData icon;

  const _MinimalIconContainer({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacityCompat(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: 20),
    );
  }
}

class _MinimalScore extends StatelessWidget {
  final int score;

  const _MinimalScore({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Score',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacityCompat(0.5),
            fontWeight: FontWeight.w500,

            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: 5),
        Text(
          '$score',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

Widget _buildMinimalChip(String text, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: theme.colorScheme.outline, width: 1.0),
    ),
    child: Text(
      text.isEmpty ? '' : '${text[0].toUpperCase()}${text.substring(1)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacityCompat(0.8),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
}

Widget _buildMinimalInfo(IconData icon, String text, ThemeData theme) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 14,
        color: theme.colorScheme.onSurface.withOpacityCompat(0.5),
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacityCompat(0.7),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}

voice.InterviewConfig _createInterviewConfigFromSession(
  UnifiedInterviewSession sessionData,
) {
  return voice.InterviewConfig(
    jobRole: sessionData.jobRole,
    category: _parseInterviewCategory(sessionData.category),
    difficulty: _parseInterviewDifficulty(sessionData.difficulty),
    numberOfQuestions: sessionData.totalQuestions,
  );
}

voice.InterviewSession _createInterviewSessionFromData(
  voice.InterviewConfig config,
  List<VoiceMessageModel> messages,
  VoiceEvaluationModel? evaluation,
  UnifiedInterviewSession sessionData,
) {
  // Convert VoiceMessageModel to InterviewMessage
  final interviewMessages =
      messages.map((voiceMsg) {
        return voice.InterviewMessage(
          content: voiceMsg.content ?? '',
          type: _parseMessageType(voiceMsg.messageType),
          timestamp: voiceMsg.timestamp,
        );
      }).toList();

  return voice.InterviewSession(
    config: config,
    messages: interviewMessages,
    currentQuestionNumber:
        sessionData.totalQuestions, // Set to total since it's completed
    status:
        sessionData.isCompleted
            ? voice.InterviewStatus.completed
            : voice.InterviewStatus.inProgress,
    isListening: false,
    isSpeaking: false,
    currentUserResponse: '',
  );
}

voice.InterviewCategory _parseInterviewCategory(String category) {
  switch (category.toLowerCase()) {
    case 'behavioral':
      return voice.InterviewCategory.behavioral;
    case 'technical':
      return voice.InterviewCategory.technical;
    case 'industry_specific':
    case 'industryspecific':
      return voice.InterviewCategory.industrySpecific;
    default:
      return voice.InterviewCategory.general;
  }
}

voice.InterviewDifficulty _parseInterviewDifficulty(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'intermediate':
      return voice.InterviewDifficulty.intermediate;
    case 'advanced':
      return voice.InterviewDifficulty.advanced;
    default:
      return voice.InterviewDifficulty.beginner;
  }
}

voice.MessageType _parseMessageType(String messageType) {
  switch (messageType.toLowerCase()) {
    case 'ai':
      return voice.MessageType.ai;
    case 'user':
      return voice.MessageType.user;
    case 'system':
      return voice.MessageType.system;
    default:
      return voice.MessageType.user;
  }
}

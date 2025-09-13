import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import '../../domain/entities/interview_message.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

class ConversationDisplayWidget extends StatelessWidget {
  final List<InterviewMessage> messages;
  final String title;

  const ConversationDisplayWidget({
    super.key,
    required this.messages,
    this.title = 'Interview Conversation',
  });

  @override
  Widget build(BuildContext context) {
    // Sort messages by timestamp to ensure correct chronological order
    final sortedMessages = List<InterviewMessage>.from(messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Debug: Print sorted message order
    AppLogger.debug('=== CONVERSATION DISPLAY MESSAGE ORDER ===');
    for (int i = 0; i < sortedMessages.length; i++) {
      final msg = sortedMessages[i];
      AppLogger.debug(
        'Message $i: ${msg.type} - ${msg.timestamp} - ${msg.content.substring(0, msg.content.length > 30 ? 30 : msg.content.length)}...',
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Use Expanded to make it fill available space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: ListView.builder(
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
}

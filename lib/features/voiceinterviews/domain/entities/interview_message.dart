class InterviewMessage {
  final String content;
  final MessageType type;
  final DateTime timestamp;

  const InterviewMessage({
    required this.content,
    required this.type,
    required this.timestamp,
  });
}

enum MessageType { user, ai, error, system }

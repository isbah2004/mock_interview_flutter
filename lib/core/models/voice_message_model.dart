import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/constants/database_constants.dart';

class VoiceMessageModel extends Equatable {
  final String messageId;
  final String sessionId;
  final String messageType; // 'ai', 'user', 'system'
  final String? content;
  final DateTime timestamp;
  final int sequenceNumber;

  const VoiceMessageModel({
    required this.messageId,
    required this.sessionId,
    required this.messageType,
    this.content,
    required this.timestamp,
    required this.sequenceNumber,
  });

  factory VoiceMessageModel.fromAppwrite(Map<String, dynamic> document) {
    return VoiceMessageModel(
      messageId: document['\$id'] ?? '',
      sessionId: document['sessionId'] ?? '',
      messageType: document['messageType'] ?? DatabaseConstants.messageTypeUser,
      content: document['content'],
      timestamp: DateTime.parse(document['timestamp']),
      sequenceNumber: document['sequenceNumber'] ?? 0,
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'sessionId': sessionId,
      'messageType': messageType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sequenceNumber': sequenceNumber,
    };
  }

  factory VoiceMessageModel.fromInterviewMessage({
    required String sessionId,
    required String messageType,
    required String content,
    required DateTime timestamp,
    required int sequenceNumber,
  }) {
    return VoiceMessageModel(
      messageId: '', // Will be set by Appwrite
      sessionId: sessionId,
      messageType: messageType,
      content: content,
      timestamp: timestamp,
      sequenceNumber: sequenceNumber,
    );
  }

  VoiceMessageModel copyWith({
    String? messageId,
    String? sessionId,
    String? messageType,
    String? content,
    DateTime? timestamp,
    int? sequenceNumber,
  }) {
    return VoiceMessageModel(
      messageId: messageId ?? this.messageId,
      sessionId: sessionId ?? this.sessionId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    sessionId,
    messageType,
    content,
    timestamp,
    sequenceNumber,
  ];
}

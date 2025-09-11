import 'package:mock_interview/core/models/mcq_question_model.dart';

/// Session Management Data Class for MCQ interviews
class MCQSessionData {
  final String sessionId;
  final String jobRole;
  final String difficulty;
  final String category;
  final int numQuestions;
  final List<McqQuestionModel> questions;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isComplete;

  MCQSessionData({
    required this.sessionId,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.numQuestions,
    required this.questions,
    required this.createdAt,
    required this.lastActivity,
    this.isComplete = false,
  });

  MCQSessionData copyWith({
    String? sessionId,
    String? jobRole,
    String? difficulty,
    String? category,
    int? numQuestions,
    List<McqQuestionModel>? questions,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool? isComplete,
  }) {
    return MCQSessionData(
      sessionId: sessionId ?? this.sessionId,
      jobRole: jobRole ?? this.jobRole,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      numQuestions: numQuestions ?? this.numQuestions,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  bool get isExpired {
    return DateTime.now().difference(lastActivity).inSeconds >
        3600; // 1 hour TTL
  }
}

/// Session Manager for MCQ interviews
class MCQSessionManager {
  final Map<String, MCQSessionData> _activeSessions = {};
  final int _maxSessions = 100;

  /// Store a new session
  void storeSession(
    String sessionId,
    String jobRole,
    String difficultyLevel,
    String category,
    List<McqQuestionModel> questions,
  ) {
    final now = DateTime.now();
    _activeSessions[sessionId] = MCQSessionData(
      sessionId: sessionId,
      jobRole: jobRole,
      difficulty: difficultyLevel,
      category: category,
      numQuestions: questions.length,
      questions: questions,
      createdAt: now,
      lastActivity: now,
    );
  }

  /// Get session data
  MCQSessionData? getSession(String sessionId) {
    return _activeSessions[sessionId];
  }

  /// Clean up expired sessions
  void cleanupExpiredSessions() {
    _activeSessions.removeWhere((key, value) => value.isExpired);
  }

  /// Check if we can create new sessions
  bool canCreateNewSession() {
    return _activeSessions.length < _maxSessions;
  }

  /// Clear all sessions
  void clearAllSessions() {
    _activeSessions.clear();
  }

  /// Get active session count
  int get activeSessionCount => _activeSessions.length;
}

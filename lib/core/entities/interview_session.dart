import 'package:equatable/equatable.dart';

enum DifficultyLevel { easy, medium, hard }

enum QuestionCategory { general, technical, behavioral, industry_specific }

enum InterviewType { behavioral, technical, industrySpecific, mcq, voice }

class InterviewSession extends Equatable {
  final String sessionId;
  final String userId;
  final String jobRole;
  final InterviewType type; // Changed from interviewType
  final DifficultyLevel difficulty; // Changed from difficultyLevel
  final QuestionCategory category;
  final int? numQuestions; // Only for MCQ
  final DateTime createdAt;
  final bool isComplete;

  // Additional properties expected by the view
  final double score; // Interview score (0-100)
  final Duration duration; // Time taken for interview
  final String? feedback; // AI feedback

  const InterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.type,
    required this.difficulty,
    required this.category,
    this.numQuestions,
    required this.createdAt,
    this.isComplete = false,
    this.score = 0.0,
    this.duration = Duration.zero,
    this.feedback,
  });

  // Factory constructor for backward compatibility
  factory InterviewSession.legacy({
    required String sessionId,
    required String userId,
    required String jobRole,
    required InterviewType interviewType,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    int? numQuestions,
    required DateTime createdAt,
    bool isComplete = false,
  }) {
    return InterviewSession(
      sessionId: sessionId,
      userId: userId,
      jobRole: jobRole,
      type: interviewType,
      difficulty: difficultyLevel,
      category: category,
      numQuestions: numQuestions,
      createdAt: createdAt,
      isComplete: isComplete,
    );
  }

  // Convenience getters for backward compatibility
  InterviewType get interviewType => type;
  DifficultyLevel get difficultyLevel => difficulty;

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    jobRole,
    type,
    difficulty,
    category,
    numQuestions,
    createdAt,
    isComplete,
    score,
    duration,
    feedback,
  ];

  InterviewSession copyWith({
    String? sessionId,
    String? userId,
    String? jobRole,
    InterviewType? type,
    DifficultyLevel? difficulty,
    QuestionCategory? category,
    int? numQuestions,
    DateTime? createdAt,
    bool? isComplete,
    double? score,
    Duration? duration,
    String? feedback,
  }) {
    return InterviewSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      jobRole: jobRole ?? this.jobRole,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      numQuestions: numQuestions ?? this.numQuestions,
      createdAt: createdAt ?? this.createdAt,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
      duration: duration ?? this.duration,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'jobRole': jobRole,
      'type': type.name,
      'difficulty': difficulty.name,
      'category': category.name,
      'numQuestions': numQuestions,
      'createdAt': createdAt.toIso8601String(),
      'isComplete': isComplete,
      'score': score,
      'duration': duration.inSeconds,
      'feedback': feedback,
    };
  }

  factory InterviewSession.fromMap(Map<String, dynamic> map) {
    return InterviewSession(
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      jobRole: map['jobRole'] ?? '',
      type: InterviewType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InterviewType.mcq,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => QuestionCategory.general,
      ),
      numQuestions: map['numQuestions'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isComplete: map['isComplete'] ?? false,
      score: (map['score'] ?? 0.0).toDouble(),
      duration: Duration(seconds: map['duration'] ?? 0),
      feedback: map['feedback'],
    );
  }
}

import '../../domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.userId,
    required super.type,
    super.jobRole,
    super.difficulty,
    super.category,
    super.score,
    required super.status,
    required super.isComplete,
    super.sessionDuration,
    super.questionsAnswered,
    required super.createdAt,
    super.completedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['\$id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      jobRole: json['jobRole'],
      difficulty: json['difficulty'],
      category: json['category'],
      score: json['score']?.toDouble(),
      status: json['status'] ?? 'started',
      isComplete: json['isComplete'] ?? false,
      sessionDuration: json['sessionDuration'],
      questionsAnswered: json['questionsAnswered'],
      createdAt: DateTime.parse(
        json['\$createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'jobRole': jobRole,
      'difficulty': difficulty,
      'category': category,
      'score': score,
      'status': status,
      'isComplete': isComplete,
      'sessionDuration': sessionDuration,
      'questionsAnswered': questionsAnswered,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      id: session.id,
      userId: session.userId,
      type: session.type,
      jobRole: session.jobRole,
      difficulty: session.difficulty,
      category: session.category,
      score: session.score,
      status: session.status,
      isComplete: session.isComplete,
      sessionDuration: session.sessionDuration,
      questionsAnswered: session.questionsAnswered,
      createdAt: session.createdAt,
      completedAt: session.completedAt,
    );
  }

  @override
  SessionModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? jobRole,
    String? difficulty,
    String? category,
    double? score,
    String? status,
    bool? isComplete,
    int? sessionDuration,
    int? questionsAnswered,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      jobRole: jobRole ?? this.jobRole,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      score: score ?? this.score,
      status: status ?? this.status,
      isComplete: isComplete ?? this.isComplete,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

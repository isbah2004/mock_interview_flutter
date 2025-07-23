import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String userId;
  final String type; // 'voice' or 'mcq'
  final String? jobRole;
  final String? difficulty;
  final String? category;
  final double? score;
  final String status;
  final bool isComplete;
  final int? sessionDuration; // in seconds
  final int? questionsAnswered;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Session({
    required this.id,
    required this.userId,
    required this.type,
    this.jobRole,
    this.difficulty,
    this.category,
    this.score,
    required this.status,
    required this.isComplete,
    this.sessionDuration,
    this.questionsAnswered,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    jobRole,
    difficulty,
    category,
    score,
    status,
    isComplete,
    sessionDuration,
    questionsAnswered,
    createdAt,
    completedAt,
  ];

  Session copyWith({
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
    return Session(
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

import 'package:equatable/equatable.dart';

abstract class MCQSetupState extends Equatable {
  const MCQSetupState();

  @override
  List<Object> get props => [];
}

class MCQSetupInitial extends MCQSetupState {
  final String difficulty;
  final String questions;
  final String category;
  final String timeLimit;
  final String jobRole;

  const MCQSetupInitial({
    this.difficulty = 'Medium',
    this.questions = '10 Questions',
    this.category = 'General',
    this.timeLimit = '30 seconds',
    this.jobRole = '',
  });

  @override
  List<Object> get props => [
    difficulty,
    questions,
    category,
    timeLimit,
    jobRole,
  ];
}

class MCQSetupUpdated extends MCQSetupState {
  final String difficulty;
  final String questions;
  final String category;
  final String timeLimit;
  final String jobRole;

  const MCQSetupUpdated({
    required this.difficulty,
    required this.questions,
    required this.category,
    required this.timeLimit,
    required this.jobRole,
  });

  @override
  List<Object> get props => [
    difficulty,
    questions,
    category,
    timeLimit,
    jobRole,
  ];

  MCQSetupUpdated copyWith({
    String? difficulty,
    String? questions,
    String? category,
    String? timeLimit,
    String? jobRole,
  }) {
    return MCQSetupUpdated(
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      category: category ?? this.category,
      timeLimit: timeLimit ?? this.timeLimit,
      jobRole: jobRole ?? this.jobRole,
    );
  }
}

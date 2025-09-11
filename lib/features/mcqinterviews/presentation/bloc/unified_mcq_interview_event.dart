import 'package:equatable/equatable.dart';
import '../../../../core/models/mcq_question_model.dart';

abstract class UnifiedMcqInterviewEvent extends Equatable {
  const UnifiedMcqInterviewEvent();

  @override
  List<Object?> get props => [];
}

// Setup Events
class InitializeMcqInterview extends UnifiedMcqInterviewEvent {
  const InitializeMcqInterview();
}

class StartJobTitleInput extends UnifiedMcqInterviewEvent {
  const StartJobTitleInput();
}

class UpdateJobTitle extends UnifiedMcqInterviewEvent {
  final String jobTitle;

  const UpdateJobTitle(this.jobTitle);

  @override
  List<Object> get props => [jobTitle];
}

class GenerateMcqQuestions extends UnifiedMcqInterviewEvent {
  final String jobTitle;
  final String difficulty;
  final String category;
  final int questionCount;

  const GenerateMcqQuestions(
    this.jobTitle, {
    this.difficulty = 'Medium',
    this.category = 'General',
    this.questionCount = 10,
  });

  @override
  List<Object> get props => [jobTitle, difficulty, category, questionCount];
}

// Interview Events
class StartMcqInterview extends UnifiedMcqInterviewEvent {
  final List<McqQuestionModel> questions;

  const StartMcqInterview(this.questions);

  @override
  List<Object> get props => [questions];
}

class LoadQuestions extends UnifiedMcqInterviewEvent {
  final List<McqQuestionModel> questions;

  const LoadQuestions(this.questions);

  @override
  List<Object> get props => [questions];
}

// Navigation Events
class SelectOption extends UnifiedMcqInterviewEvent {
  final String selectedOption;

  const SelectOption(this.selectedOption);

  @override
  List<Object> get props => [selectedOption];
}

class NavigateToNext extends UnifiedMcqInterviewEvent {
  const NavigateToNext();
}

class NavigateToPrevious extends UnifiedMcqInterviewEvent {
  const NavigateToPrevious();
}

class UpdateAnswer extends UnifiedMcqInterviewEvent {
  final int questionIndex;
  final String answer;

  const UpdateAnswer(this.questionIndex, this.answer);

  @override
  List<Object> get props => [questionIndex, answer];
}

class ClearSelection extends UnifiedMcqInterviewEvent {
  const ClearSelection();
}

// Interview Completion Events
class SubmitAnswers extends UnifiedMcqInterviewEvent {
  final List<String> answers;

  const SubmitAnswers(this.answers);

  @override
  List<Object> get props => [answers];
}

class CompleteInterview extends UnifiedMcqInterviewEvent {
  const CompleteInterview();
}

class SaveInterviewResult extends UnifiedMcqInterviewEvent {
  final String jobTitle;
  final List<McqQuestionModel> questions;
  final List<String> answers;
  final double score;

  const SaveInterviewResult({
    required this.jobTitle,
    required this.questions,
    required this.answers,
    required this.score,
  });

  @override
  List<Object> get props => [jobTitle, questions, answers, score];
}

// Reset Events
class ResetInterview extends UnifiedMcqInterviewEvent {
  const ResetInterview();
}

class RetryGeneration extends UnifiedMcqInterviewEvent {
  final String jobTitle;
  final String difficulty;
  final String category;
  final int questionCount;

  const RetryGeneration(
    this.jobTitle, {
    this.difficulty = 'Medium',
    this.category = 'General',
    this.questionCount = 10,
  });

  @override
  List<Object> get props => [jobTitle, difficulty, category, questionCount];
}

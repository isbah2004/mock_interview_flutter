import 'package:equatable/equatable.dart';
import '../../../../core/models/mcq_question_model.dart';

abstract class UnifiedMcqInterviewState extends Equatable {
  const UnifiedMcqInterviewState();

  @override
  List<Object?> get props => [];
}

// Initial State
class McqInterviewInitial extends UnifiedMcqInterviewState {
  const McqInterviewInitial();
}

// Setup States
class JobTitleInputState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final bool isValid;

  const JobTitleInputState({this.jobTitle = '', this.isValid = false});

  JobTitleInputState copyWith({String? jobTitle, bool? isValid}) {
    return JobTitleInputState(
      jobTitle: jobTitle ?? this.jobTitle,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [jobTitle, isValid];
}

class GeneratingQuestionsState extends UnifiedMcqInterviewState {
  final String jobTitle;

  const GeneratingQuestionsState(this.jobTitle);

  @override
  List<Object> get props => [jobTitle];
}

class QuestionsGeneratedState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final List<McqQuestionModel> questions;

  const QuestionsGeneratedState({
    required this.jobTitle,
    required this.questions,
  });

  @override
  List<Object> get props => [jobTitle, questions];
}

class QuestionGenerationFailedState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final String error;

  const QuestionGenerationFailedState({
    required this.jobTitle,
    required this.error,
  });

  @override
  List<Object> get props => [jobTitle, error];
}

// Interview In Progress State
class McqInterviewInProgressState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final List<McqQuestionModel> questions;
  final int currentQuestionIndex;
  final List<String> answers;
  final String? selectedOption;
  final bool canNavigateNext;
  final bool canNavigatePrevious;
  final bool isLastQuestion;

  const McqInterviewInProgressState({
    required this.jobTitle,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    this.selectedOption,
    required this.canNavigateNext,
    required this.canNavigatePrevious,
    required this.isLastQuestion,
  });

  McqInterviewInProgressState copyWith({
    String? jobTitle,
    List<McqQuestionModel>? questions,
    int? currentQuestionIndex,
    List<String>? answers,
    String? selectedOption,
    bool? canNavigateNext,
    bool? canNavigatePrevious,
    bool? isLastQuestion,
    bool clearSelection = false,
  }) {
    return McqInterviewInProgressState(
      jobTitle: jobTitle ?? this.jobTitle,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      selectedOption:
          clearSelection ? null : (selectedOption ?? this.selectedOption),
      canNavigateNext: canNavigateNext ?? this.canNavigateNext,
      canNavigatePrevious: canNavigatePrevious ?? this.canNavigatePrevious,
      isLastQuestion: isLastQuestion ?? this.isLastQuestion,
    );
  }

  McqQuestionModel get currentQuestion => questions[currentQuestionIndex];

  @override
  List<Object?> get props => [
    jobTitle,
    questions,
    currentQuestionIndex,
    answers,
    selectedOption,
    canNavigateNext,
    canNavigatePrevious,
    isLastQuestion,
  ];
}

// Interview Completion States
class McqInterviewCompletedState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final List<McqQuestionModel> questions;
  final List<String> answers;
  final double score;
  final int correctAnswers;
  final int totalQuestions;

  const McqInterviewCompletedState({
    required this.jobTitle,
    required this.questions,
    required this.answers,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  List<Object> get props => [
    jobTitle,
    questions,
    answers,
    score,
    correctAnswers,
    totalQuestions,
  ];
}

class SavingInterviewResultState extends UnifiedMcqInterviewState {
  final String jobTitle;
  final List<McqQuestionModel> questions;
  final List<String> answers;
  final double score;

  const SavingInterviewResultState({
    required this.jobTitle,
    required this.questions,
    required this.answers,
    required this.score,
  });

  @override
  List<Object> get props => [jobTitle, questions, answers, score];
}

class InterviewResultSavedState extends UnifiedMcqInterviewState {
  final String interviewId;
  final double score;

  const InterviewResultSavedState({
    required this.interviewId,
    required this.score,
  });

  @override
  List<Object> get props => [interviewId, score];
}

class InterviewSaveFailedState extends UnifiedMcqInterviewState {
  final String error;
  final String jobTitle;
  final List<McqQuestionModel> questions;
  final List<String> answers;
  final double score;

  const InterviewSaveFailedState({
    required this.error,
    required this.jobTitle,
    required this.questions,
    required this.answers,
    required this.score,
  });

  @override
  List<Object> get props => [error, jobTitle, questions, answers, score];
}

// Error States
class McqInterviewErrorState extends UnifiedMcqInterviewState {
  final String error;

  const McqInterviewErrorState(this.error);

  @override
  List<Object> get props => [error];
}

import 'package:equatable/equatable.dart';

abstract class McqNavigationState extends Equatable {
  const McqNavigationState();

  @override
  List<Object?> get props => [];
}

class McqNavigationInitial extends McqNavigationState {}

class McqNavigationReady extends McqNavigationState {
  final int currentQuestionIndex;
  final List<String> answers;
  final String? selectedOption;
  final int totalQuestions;
  final bool canNavigateNext;
  final bool canNavigatePrevious;

  const McqNavigationReady({
    required this.currentQuestionIndex,
    required this.answers,
    this.selectedOption,
    required this.totalQuestions,
    required this.canNavigateNext,
    required this.canNavigatePrevious,
  });

  McqNavigationReady copyWith({
    int? currentQuestionIndex,
    List<String>? answers,
    String? selectedOption,
    int? totalQuestions,
    bool? canNavigateNext,
    bool? canNavigatePrevious,
    bool clearSelection = false,
  }) {
    return McqNavigationReady(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      selectedOption:
          clearSelection ? null : (selectedOption ?? this.selectedOption),
      totalQuestions: totalQuestions ?? this.totalQuestions,
      canNavigateNext: canNavigateNext ?? this.canNavigateNext,
      canNavigatePrevious: canNavigatePrevious ?? this.canNavigatePrevious,
    );
  }

  @override
  List<Object?> get props => [
    currentQuestionIndex,
    answers,
    selectedOption,
    totalQuestions,
    canNavigateNext,
    canNavigatePrevious,
  ];
}

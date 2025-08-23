import 'package:bloc/bloc.dart';

import 'mcq_navigation_event.dart';
import 'mcq_navigation_state.dart';

class McqNavigationBloc extends Bloc<McqNavigationEvent, McqNavigationState> {
  McqNavigationBloc() : super(McqNavigationInitial()) {
    on<InitializeNavigation>(_onInitializeNavigation);
    on<SelectOption>(_onSelectOption);
    on<NavigateToNext>(_onNavigateToNext);
    on<NavigateToPrevious>(_onNavigateToPrevious);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<ClearSelection>(_onClearSelection);
  }

  void _onInitializeNavigation(
    InitializeNavigation event,
    Emitter<McqNavigationState> emit,
  ) {
    final answers = List<String>.filled(event.totalQuestions, '');
    emit(
      McqNavigationReady(
        currentQuestionIndex: 0,
        answers: answers,
        selectedOption: null,
        totalQuestions: event.totalQuestions,
        canNavigateNext: false,
        canNavigatePrevious: false,
      ),
    );
  }

  void _onSelectOption(SelectOption event, Emitter<McqNavigationState> emit) {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;
      emit(
        currentState.copyWith(
          selectedOption: event.selectedOption,
          canNavigateNext: true,
        ),
      );
    }
  }

  void _onNavigateToNext(
    NavigateToNext event,
    Emitter<McqNavigationState> emit,
  ) {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;

      if (currentState.selectedOption != null &&
          currentState.currentQuestionIndex < currentState.totalQuestions - 1) {
        // Update current answer
        final updatedAnswers = List<String>.from(currentState.answers);
        updatedAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;

        final newIndex = currentState.currentQuestionIndex + 1;
        final nextAnswer = updatedAnswers[newIndex];

        emit(
          currentState.copyWith(
            currentQuestionIndex: newIndex,
            answers: updatedAnswers,
            selectedOption: nextAnswer.isNotEmpty ? nextAnswer : null,
            canNavigateNext: nextAnswer.isNotEmpty,
            canNavigatePrevious: true,
          ),
        );
      }
    }
  }

  void _onNavigateToPrevious(
    NavigateToPrevious event,
    Emitter<McqNavigationState> emit,
  ) {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;

      if (currentState.currentQuestionIndex > 0) {
        final newIndex = currentState.currentQuestionIndex - 1;
        final previousAnswer = currentState.answers[newIndex];

        emit(
          currentState.copyWith(
            currentQuestionIndex: newIndex,
            selectedOption: previousAnswer.isNotEmpty ? previousAnswer : null,
            canNavigateNext: previousAnswer.isNotEmpty,
            canNavigatePrevious: newIndex > 0,
          ),
        );
      }
    }
  }

  void _onUpdateAnswer(UpdateAnswer event, Emitter<McqNavigationState> emit) {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;
      final updatedAnswers = List<String>.from(currentState.answers);
      updatedAnswers[event.questionIndex] = event.answer;

      emit(currentState.copyWith(answers: updatedAnswers));
    }
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<McqNavigationState> emit,
  ) {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;
      emit(currentState.copyWith(clearSelection: true, canNavigateNext: false));
    }
  }

  // Helper methods
  bool get isLastQuestion {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;
      return currentState.currentQuestionIndex ==
          currentState.totalQuestions - 1;
    }
    return false;
  }

  List<String> get currentAnswers {
    if (state is McqNavigationReady) {
      final currentState = state as McqNavigationReady;
      // Update current answer if there's a selection
      if (currentState.selectedOption != null) {
        final updatedAnswers = List<String>.from(currentState.answers);
        updatedAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;
        return updatedAnswers;
      }
      return currentState.answers;
    }
    return [];
  }
}

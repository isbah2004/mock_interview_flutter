import 'package:bloc/bloc.dart';

import 'mcq_setup_event.dart';
import 'mcq_setup_state.dart';

class McqSetupBloc extends Bloc<McqSetupEvent, McqSetupState> {
  McqSetupBloc() : super(McqSetupInitial()) {
    on<UpdateJobRole>(_onUpdateJobRole);
    on<UpdateDifficulty>(_onUpdateDifficulty);
    on<UpdateCategory>(_onUpdateCategory);
    on<UpdateQuestionCount>(_onUpdateQuestionCount);
    on<ValidateForm>(_onValidateForm);
    on<ResetForm>(_onResetForm);

    // Initialize with default values
    add(const UpdateJobRole(''));
  }

  void _onUpdateJobRole(UpdateJobRole event, Emitter<McqSetupState> emit) {
    final currentState = _getCurrentState();
    final newState = currentState.copyWith(
      jobRole: event.jobRole,
      isFormValid: _isFormValid(
        event.jobRole,
        currentState.selectedDifficulty,
        currentState.selectedCategory,
        currentState.selectedQuestions,
      ),
    );
    emit(newState);
  }

  void _onUpdateDifficulty(
    UpdateDifficulty event,
    Emitter<McqSetupState> emit,
  ) {
    final currentState = _getCurrentState();
    final newState = currentState.copyWith(
      selectedDifficulty: event.difficulty,
      isFormValid: _isFormValid(
        currentState.jobRole,
        event.difficulty,
        currentState.selectedCategory,
        currentState.selectedQuestions,
      ),
    );
    emit(newState);
  }

  void _onUpdateCategory(UpdateCategory event, Emitter<McqSetupState> emit) {
    final currentState = _getCurrentState();
    final newState = currentState.copyWith(
      selectedCategory: event.category,
      isFormValid: _isFormValid(
        currentState.jobRole,
        currentState.selectedDifficulty,
        event.category,
        currentState.selectedQuestions,
      ),
    );
    emit(newState);
  }

  void _onUpdateQuestionCount(
    UpdateQuestionCount event,
    Emitter<McqSetupState> emit,
  ) {
    final currentState = _getCurrentState();
    final newState = currentState.copyWith(
      selectedQuestions: event.questionCount,
      isFormValid: _isFormValid(
        currentState.jobRole,
        currentState.selectedDifficulty,
        currentState.selectedCategory,
        event.questionCount,
      ),
    );
    emit(newState);
  }

  void _onValidateForm(ValidateForm event, Emitter<McqSetupState> emit) {
    final currentState = _getCurrentState();
    final isValid = _isFormValid(
      currentState.jobRole,
      currentState.selectedDifficulty,
      currentState.selectedCategory,
      currentState.selectedQuestions,
    );
    emit(currentState.copyWith(isFormValid: isValid));
  }

  void _onResetForm(ResetForm event, Emitter<McqSetupState> emit) {
    emit(
      const McqSetupConfiguring(
        jobRole: '',
        selectedDifficulty: 'easy',
        selectedCategory: 'general',
        selectedQuestions: 5,
        isFormValid: false,
      ),
    );
  }

  McqSetupConfiguring _getCurrentState() {
    if (state is McqSetupConfiguring) {
      return state as McqSetupConfiguring;
    }
    return const McqSetupConfiguring(
      jobRole: '',
      selectedDifficulty: 'easy',
      selectedCategory: 'general',
      selectedQuestions: 5,
      isFormValid: false,
    );
  }

  bool _isFormValid(
    String jobRole,
    String difficulty,
    String category,
    int questions,
  ) {
    return jobRole.trim().isNotEmpty &&
        difficulty.isNotEmpty &&
        category.isNotEmpty &&
        questions > 0 &&
        questions <= 20;
  }
}

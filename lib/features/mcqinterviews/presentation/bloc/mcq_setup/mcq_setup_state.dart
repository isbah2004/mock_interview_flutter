import 'package:equatable/equatable.dart';

abstract class McqSetupState extends Equatable {
  const McqSetupState();

  @override
  List<Object?> get props => [];
}

class McqSetupInitial extends McqSetupState {}

class McqSetupConfiguring extends McqSetupState {
  final String jobRole;
  final String selectedDifficulty;
  final String selectedCategory;
  final int selectedQuestions;
  final bool isFormValid;

  const McqSetupConfiguring({
    required this.jobRole,
    required this.selectedDifficulty,
    required this.selectedCategory,
    required this.selectedQuestions,
    required this.isFormValid,
  });

  McqSetupConfiguring copyWith({
    String? jobRole,
    String? selectedDifficulty,
    String? selectedCategory,
    int? selectedQuestions,
    bool? isFormValid,
  }) {
    return McqSetupConfiguring(
      jobRole: jobRole ?? this.jobRole,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedQuestions: selectedQuestions ?? this.selectedQuestions,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [
    jobRole,
    selectedDifficulty,
    selectedCategory,
    selectedQuestions,
    isFormValid,
  ];
}

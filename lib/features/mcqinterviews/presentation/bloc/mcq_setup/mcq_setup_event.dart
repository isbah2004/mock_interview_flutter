import 'package:equatable/equatable.dart';

abstract class McqSetupEvent extends Equatable {
  const McqSetupEvent();

  @override
  List<Object> get props => [];
}

class UpdateJobRole extends McqSetupEvent {
  final String jobRole;

  const UpdateJobRole(this.jobRole);

  @override
  List<Object> get props => [jobRole];
}

class UpdateDifficulty extends McqSetupEvent {
  final String difficulty;

  const UpdateDifficulty(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class UpdateCategory extends McqSetupEvent {
  final String category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateQuestionCount extends McqSetupEvent {
  final int questionCount;

  const UpdateQuestionCount(this.questionCount);

  @override
  List<Object> get props => [questionCount];
}

class ValidateForm extends McqSetupEvent {}

class ResetForm extends McqSetupEvent {}

import 'package:equatable/equatable.dart';

abstract class McqNavigationEvent extends Equatable {
  const McqNavigationEvent();

  @override
  List<Object> get props => [];
}

class InitializeNavigation extends McqNavigationEvent {
  final int totalQuestions;

  const InitializeNavigation(this.totalQuestions);

  @override
  List<Object> get props => [totalQuestions];
}

class SelectOption extends McqNavigationEvent {
  final String selectedOption;

  const SelectOption(this.selectedOption);

  @override
  List<Object> get props => [selectedOption];
}

class NavigateToNext extends McqNavigationEvent {}

class NavigateToPrevious extends McqNavigationEvent {}

class UpdateAnswer extends McqNavigationEvent {
  final int questionIndex;
  final String answer;

  const UpdateAnswer(this.questionIndex, this.answer);

  @override
  List<Object> get props => [questionIndex, answer];
}

class ClearSelection extends McqNavigationEvent {}

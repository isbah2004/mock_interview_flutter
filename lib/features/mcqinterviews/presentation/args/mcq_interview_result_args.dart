import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';

class InterviewResultArgs extends Equatable {
  final EvaluationResultModel evaluationResult;

  const InterviewResultArgs({required this.evaluationResult});

  @override
  List<Object?> get props => [evaluationResult];
}

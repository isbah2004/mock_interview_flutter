import 'package:equatable/equatable.dart';

class PerformanceSummary extends Equatable {
  final int totalCorrect;
  final int totalIncorrect;
  final Map<String, int> scoreDistribution;

  const PerformanceSummary({
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.scoreDistribution,
  });

  @override
  List<Object?> get props => [totalCorrect, totalIncorrect, scoreDistribution];

  int get totalQuestions => totalCorrect + totalIncorrect;
  double get accuracyPercentage => 
    totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

  bool get hasPerfectScore => scoreDistribution['perfect_scores'] != null && 
    scoreDistribution['perfect_scores']! > 0;
  
  bool get hasZeroScores => scoreDistribution['zero_scores'] != null && 
    scoreDistribution['zero_scores']! > 0;

  PerformanceSummary copyWith({
    int? totalCorrect,
    int? totalIncorrect,
    Map<String, int>? scoreDistribution,
  }) {
    return PerformanceSummary(
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      scoreDistribution: scoreDistribution ?? this.scoreDistribution,
    );
  }
}
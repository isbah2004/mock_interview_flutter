import 'dart:convert';

import 'package:mock_interview/core/entities/performance_summary.dart';

class PerformanceSummaryModel extends PerformanceSummary {
  const PerformanceSummaryModel({
    required super.totalCorrect,
    required super.totalIncorrect,
    required super.scoreDistribution,
  });

 
  factory PerformanceSummaryModel.fromEntity(PerformanceSummary entity) {
    return PerformanceSummaryModel(
      totalCorrect: entity.totalCorrect,
      totalIncorrect: entity.totalIncorrect,
      scoreDistribution: entity.scoreDistribution,
    );
  }

 
  PerformanceSummary toEntity() {
    return PerformanceSummary(
      totalCorrect: totalCorrect,
      totalIncorrect: totalIncorrect,
      scoreDistribution: scoreDistribution,
    );
  }

 
  factory PerformanceSummaryModel.fromAIResponse(Map<String, dynamic> json) {
    return PerformanceSummaryModel(
      totalCorrect: json['total_correct'] ?? 0,
      totalIncorrect: json['total_incorrect'] ?? 0,
      scoreDistribution: Map<String, int>.from(json['score_distribution'] ?? {}),
    );
  }

  Map<String, dynamic> toAIResponse() {
    return {
      'total_correct': totalCorrect,
      'total_incorrect': totalIncorrect,
      'score_distribution': scoreDistribution,
    };
  }

 
  factory PerformanceSummaryModel.fromAppwrite(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return PerformanceSummaryModel.fromAIResponse(json);
    } catch (e) {
      return const PerformanceSummaryModel(
        totalCorrect: 0,
        totalIncorrect: 0,
        scoreDistribution: {},
      );
    }
  }

  String toAppwrite() {
    return jsonEncode(toAIResponse());
  }
}
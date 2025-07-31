import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int totalInterviews;
  final double averageScore;
  final int voiceInterviews;
  final int mcqInterviews;
  final double improvementPercentage;
  final String userId;

  const UserStats({
    required this.totalInterviews,
    required this.averageScore,
    required this.voiceInterviews,
    required this.mcqInterviews,
    required this.improvementPercentage,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    totalInterviews,
    averageScore,
    voiceInterviews,
    mcqInterviews,
    improvementPercentage,
    userId,
  ];

  UserStats copyWith({
    int? totalInterviews,
    double? averageScore,
    int? voiceInterviews,
    int? mcqInterviews,
    double? improvementPercentage,
    String? userId,
  }) {
    return UserStats(
      totalInterviews: totalInterviews ?? this.totalInterviews,
      averageScore: averageScore ?? this.averageScore,
      voiceInterviews: voiceInterviews ?? this.voiceInterviews,
      mcqInterviews: mcqInterviews ?? this.mcqInterviews,
      improvementPercentage:
          improvementPercentage ?? this.improvementPercentage,
      userId: userId ?? this.userId,
    );
  }
}

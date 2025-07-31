import '../../../../core/entities/user_stats.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.totalInterviews,
    required super.averageScore,
    required super.voiceInterviews,
    required super.mcqInterviews,
    required super.improvementPercentage,
    required super.userId,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalInterviews: json['totalInterviews'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      voiceInterviews: json['voiceInterviews'] ?? 0,
      mcqInterviews: json['mcqInterviews'] ?? 0,
      improvementPercentage: (json['improvementPercentage'] ?? 0.0).toDouble(),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInterviews': totalInterviews,
      'averageScore': averageScore,
      'voiceInterviews': voiceInterviews,
      'mcqInterviews': mcqInterviews,
      'improvementPercentage': improvementPercentage,
      'userId': userId,
    };
  }

  factory UserStatsModel.fromUserData(Map<String, dynamic> userData) {
    return UserStatsModel(
      totalInterviews: userData['totalInterviews'] ?? 0,
      averageScore: (userData['averageScore'] ?? 0.0).toDouble(),
      voiceInterviews: userData['voiceInterviews'] ?? 0,
      mcqInterviews: userData['mcqInterviews'] ?? 0,
      improvementPercentage: 0.0, // Calculate based on historical data
      userId: userData['\$id'] ?? userData['userId'] ?? '',
    );
  }

  @override
  UserStatsModel copyWith({
    int? totalInterviews,
    double? averageScore,
    int? voiceInterviews,
    int? mcqInterviews,
    double? improvementPercentage,
    String? userId,
  }) {
    return UserStatsModel(
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

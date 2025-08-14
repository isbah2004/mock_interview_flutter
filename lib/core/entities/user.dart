import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/auth_provider.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final int totalInterviews;
  final int voiceInterviews;
  final int mcqInterviews;
  final double averageScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;
  final AuthType provider;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.totalInterviews,
    required this.averageScore,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    required this.voiceInterviews,
    required this.mcqInterviews,
    required this.provider,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    totalInterviews,
    averageScore,
    createdAt,
    updatedAt,
    photoUrl,
    provider,
    voiceInterviews,
    mcqInterviews,
  ];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    int? totalInterviews,
    double? averageScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoUrl,
    AuthType? provider,
    int? voiceInterviews,
    int? mcqInterviews,
  }) {
    return UserEntity(
      voiceInterviews: voiceInterviews ?? this.voiceInterviews,
      mcqInterviews: mcqInterviews ?? this.mcqInterviews,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalInterviews: totalInterviews ?? this.totalInterviews,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
    );
  }
}

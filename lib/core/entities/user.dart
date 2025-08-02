import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? provider;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  final int totalInterviews;
  final double averageScore;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.provider,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
    this.totalInterviews = 0,
    this.averageScore = 0.0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    provider,
    createdAt,
    updatedAt,
    preferences,
    totalInterviews,
    averageScore,
  ];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    int? totalInterviews,
    double? averageScore,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      totalInterviews: totalInterviews ?? this.totalInterviews,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}

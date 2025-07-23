import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final String? photoUrl;
  final String? provider;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  final int totalInterviews;
  final double averageScore;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    this.photoUrl,
    this.provider,
    this.phone,
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
    isEmailVerified,
    photoUrl,
    provider,
    phone,
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
    bool? isEmailVerified,
    String? photoUrl,
    String? provider,
    String? phone,
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
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      totalInterviews: totalInterviews ?? this.totalInterviews,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}

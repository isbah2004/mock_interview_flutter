import 'package:mock_interview/core/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,

    super.photoUrl,
    super.provider,

    required super.createdAt,
    super.updatedAt,
    super.preferences,
    super.totalInterviews,
    super.averageScore,
  });

  factory UserModel.fromAppwriteUser(User user, {String? provider}) {
    return UserModel(
      id: user.id,
      name: user.userMetadata!['name'] ?? '',
      email: user.email ?? '',

      photoUrl: user.userMetadata!['photoUrl'],
      provider: provider ?? 'email',

      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(
        user.updatedAt ?? DateTime.now().toIso8601String(),
      ),
      preferences: user.userMetadata!,
      totalInterviews: user.userMetadata!['totalInterviews'] ?? 0,
      averageScore: user.userMetadata!['averageScore']?.toDouble() ?? 0.0,
    );
  }

  factory UserModel.fromAppwriteDocument(Map<String, dynamic> doc) {
    return UserModel(
      id: doc['\$id'],
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',

      photoUrl: doc['photoUrl'],
      provider: doc['provider'] ?? 'email',

      createdAt: DateTime.parse(doc['\$createdAt']),
      updatedAt: DateTime.parse(doc['\$updatedAt']),
      preferences: doc['preferences'],
      totalInterviews: doc['totalInterviews'] ?? 0,
      averageScore: doc['averageScore']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toAppwriteDocument() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider,

      'preferences': preferences,
      'totalInterviews': totalInterviews,
      'averageScore': averageScore,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,

      'photoUrl': photoUrl,
      'provider': provider,

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferences': preferences,
      'totalInterviews': totalInterviews,
      'averageScore': averageScore,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      provider: json['provider'],

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      preferences: json['preferences'],
      totalInterviews: json['totalInterviews'] ?? 0,
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    int? totalInterviews,
    double? averageScore,
  }) {
    return UserModel(
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

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      provider: entity.provider,

      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      preferences: entity.preferences,
      totalInterviews: entity.totalInterviews,
      averageScore: entity.averageScore,
    );
  }
}

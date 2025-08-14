import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/enums/auth_provider.dart';
import 'package:mock_interview/core/extensions/auth_provider_extension.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.totalInterviews,
    required super.averageScore,
    required super.createdAt,
    required super.updatedAt,
    super.photoUrl,
    required super.provider,
    required super.voiceInterviews,
    required super.mcqInterviews,
  });

  factory UserModel.fromFirebaseUser(User user, {AuthType? provider}) {
    return UserModel(
      voiceInterviews: 0,
      mcqInterviews: 0,
      id: user.uid,
      name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      provider: provider ?? AuthType.email,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
      totalInterviews: 0,
      averageScore: 0.0,
    );
  }

  factory UserModel.fromAppwriteDocument(Map<String, dynamic> doc) {
    return UserModel(
      id: doc['\$id'],
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      photoUrl: doc['photoUrl'],
      provider: AuthProviderExtension.fromString(doc['provider'] ?? 'email'),
      createdAt: DateTime.parse(doc['\$createdAt']),
      updatedAt: DateTime.parse(doc['\$updatedAt']),
      totalInterviews: doc['totalInterviews'] ?? 0,
      averageScore: doc['averageScore']?.toDouble() ?? 0.0,
      voiceInterviews: doc['voiceInterviews'] ?? 0,
      mcqInterviews: doc['mcqInterviews'] ?? 0,
    );
  }

  Map<String, dynamic> toAppwriteDocument() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider.value,
      'totalInterviews': totalInterviews,
      'averageScore': averageScore,
      'voiceInterviews': voiceInterviews,
      'mcqInterviews': mcqInterviews,
      'updatedAt':updatedAt.toIso8601String(),

    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalInterviews': totalInterviews,
      'averageScore': averageScore,
      'voiceInterviews': voiceInterviews,
      'mcqInterviews': mcqInterviews,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      provider: AuthProviderExtension.fromString(json['provider']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      totalInterviews: json['totalInterviews'] ?? 0,
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
      voiceInterviews: json['voiceInterviews'] ?? 0,
      mcqInterviews: json['mcqInterviews'] ?? 0,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalInterviews: totalInterviews ?? this.totalInterviews,
      averageScore: averageScore ?? this.averageScore,
      voiceInterviews: voiceInterviews ?? this.voiceInterviews,
      mcqInterviews: mcqInterviews ?? this.mcqInterviews, 
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
      totalInterviews: entity.totalInterviews,
      averageScore: entity.averageScore,
      voiceInterviews: entity.voiceInterviews,
      mcqInterviews: entity.mcqInterviews,
    );
  }
}

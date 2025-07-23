import 'package:appwrite/models.dart' as appwrite;
import 'package:mock_interview/core/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.isEmailVerified,
    super.photoUrl,
    super.provider,
    super.phone,
    required super.createdAt,
    super.updatedAt,
    super.preferences,
    super.totalInterviews,
    super.averageScore,
  });

  factory UserModel.fromAppwriteUser(appwrite.User user, {String? provider}) {
    return UserModel(
      id: user.$id,
      name: user.name,
      email: user.email,
      isEmailVerified: user.emailVerification,
      photoUrl: user.prefs.data['photoUrl'],
      provider: provider ?? 'email',
      phone: user.phone,
      createdAt: DateTime.parse(user.$createdAt),
      updatedAt: DateTime.parse(user.$updatedAt),
      preferences: user.prefs.data,
      totalInterviews: user.prefs.data['totalInterviews'] ?? 0,
      averageScore: user.prefs.data['averageScore']?.toDouble() ?? 0.0,
    );
  }

  factory UserModel.fromAppwriteDocument(Map<String, dynamic> doc) {
    return UserModel(
      id: doc['\$id'],
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      isEmailVerified: doc['emailVerification'] ?? false,
      photoUrl: doc['photoUrl'],
      provider: doc['provider'] ?? 'email',
      phone: doc['phone'],
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
      'emailVerification': isEmailVerified,
      'photoUrl': photoUrl,
      'provider': provider,
      'phone': phone,
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
      'emailVerification': isEmailVerified,
      'photoUrl': photoUrl,
      'provider': provider,
      'phone': phone,
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
      isEmailVerified: json['emailVerification'],
      photoUrl: json['photoUrl'],
      provider: json['provider'],
      phone: json['phone'],
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
    String? phone,
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

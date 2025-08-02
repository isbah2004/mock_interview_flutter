import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';

import 'package:mock_interview/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> verifyEmail({
    required String userId,
    required String secret,
  });
  Future<Either<Failure, void>> updateProfile({
    required String name,

  });
  Future<Either<Failure, String>> uploadProfileImage(String imagePath);
  Stream<UserEntity?> get authStateChanges;
}

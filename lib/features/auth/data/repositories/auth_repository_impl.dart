import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/core/utils/app_logger.dart';
import 'package:mock_interview/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mock_interview/features/auth/data/models/user_model.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkService networkService;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkService,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.signInWithEmail(email, password);

      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String name,
    required String password,
  }) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.signUpWithEmail(
        email,
        password,
        name,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.signInWithFacebook();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = remoteDataSource.currentUser;
      if (user == null) {
        return const Right(null);
      }

      // Try to get updated user data from Appwrite
      try {
        final appwriteDoc = await remoteDataSource.getUserFromAppwrite(
          user.uid,
        );
        if (appwriteDoc != null) {
          // Return user data from Appwrite (includes updated stats)
          return Right(UserModel.fromAppwriteDocument(appwriteDoc));
        }
      } catch (e) {
        // If Appwrite data doesn't exist, fall back to Firebase data
        AppLogger.warn('Could not fetch user from Appwrite: $e');
      }

      // Fallback to Firebase user data (basic profile, no stats)
      return Right(UserModel.fromFirebaseUser(user));
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail({required String otp}) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.verifyEmail(otp);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({required String name}) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.updateProfile(name);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String imagePath) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(imagePath);
      return Right(imageUrl);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      try {
        final user = remoteDataSource.currentUser;
        if (user == null) return null;

        return UserModel.fromFirebaseUser(user);
      } catch (e) {
        return null;
      }
    }).distinct();
  }
}

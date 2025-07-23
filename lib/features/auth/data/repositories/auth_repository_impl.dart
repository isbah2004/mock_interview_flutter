import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkService networkService;

  AuthRepositoryImpl({
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
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Network error occurred: ${e.toString()}'));
    }
  }

  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
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
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
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
  Future<Either<Failure, void>> verifyEmail({
    required String userId,
    required String secret,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.verifyEmail(userId, secret);
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
  Future<Either<Failure, void>> updateProfile({
    required String name,
    String? phone,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.updateProfile(name, phone: phone);
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
        return await remoteDataSource.getCurrentUser();
      } catch (e) {
        return null;
      }
    }).distinct();
  }
}

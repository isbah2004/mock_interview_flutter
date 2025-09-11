import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/features/ads/data/datasources/admob_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

class AdRepositoryImpl implements AdRepository {
  final AdRemoteDataSource remoteDataSource;

  AdRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> initializeAds() async {
    try {
      await remoteDataSource.initializeAds();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AdFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdEntity>> loadInterstitialAd(String adUnitId) async {
    try {
      final result = await remoteDataSource.loadInterstitialAd(adUnitId);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AdFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> showInterstitialAd() async {
    try {
      await remoteDataSource.showInterstitialAd();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AdFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await remoteDataSource.dispose();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AdFailure(message: e.toString()));
    }
  }
}

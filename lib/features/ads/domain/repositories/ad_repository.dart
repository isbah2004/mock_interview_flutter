import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<Either<Failure, void>> initializeAds();
  Future<Either<Failure, AdEntity>> loadInterstitialAd(String adUnitId);
  Future<Either<Failure, void>> showInterstitialAd();
  Future<Either<Failure, void>> dispose();
}

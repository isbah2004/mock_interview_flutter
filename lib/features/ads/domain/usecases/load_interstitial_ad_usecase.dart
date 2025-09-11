import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class LoadInterstitialAdParams {
  final String adUnitId;

  const LoadInterstitialAdParams({required this.adUnitId});
}

class LoadInterstitialAdUseCase
    implements UseCase<AdEntity, LoadInterstitialAdParams> {
  final AdRepository repository;

  LoadInterstitialAdUseCase(this.repository);

  @override
  Future<Either<Failure, AdEntity>> call(
    LoadInterstitialAdParams params,
  ) async {
    return await repository.loadInterstitialAd(params.adUnitId);
  }
}

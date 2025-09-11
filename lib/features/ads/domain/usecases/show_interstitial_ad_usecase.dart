import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/ad_repository.dart';

class ShowInterstitialAdUseCase implements UseCase<void, NoParams> {
  final AdRepository repository;

  ShowInterstitialAdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.showInterstitialAd();
  }
}

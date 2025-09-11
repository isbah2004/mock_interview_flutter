import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/ad_repository.dart';

class InitializeAdsUseCase {
  final AdRepository repository;

  InitializeAdsUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.initializeAds();
  }
}

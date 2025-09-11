import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/ads/presentation/bloc/ad_event.dart';
import 'package:mock_interview/features/ads/presentation/bloc/ad_state.dart';
// removed injectable import — project doesn't depend on injectable
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/usecases/initialize_ads_usecase.dart';
import '../../domain/usecases/load_interstitial_ad_usecase.dart';
import '../../domain/usecases/show_interstitial_ad_usecase.dart';
// watch usecase removed in simplified domain



// BLoC
class InterstitialAdBloc
    extends Bloc<InterstitialAdEvent, InterstitialAdState> {
  final InitializeAdsUseCase initializeAdsUseCase;
  final LoadInterstitialAdUseCase loadInterstitialAdUseCase;
  final ShowInterstitialAdUseCase showInterstitialAdUseCase;

  InterstitialAdBloc({
    required this.initializeAdsUseCase,
    required this.loadInterstitialAdUseCase,
    required this.showInterstitialAdUseCase,
  }) : super(const InterstitialAdInitial()) {
    on<InitializeAdsEvent>(_onInitializeAds);
    on<LoadInterstitialAdEvent>(_onLoadInterstitialAd);
    on<ShowInterstitialAdEvent>(_onShowInterstitialAd);
  }

  Future<void> _onInitializeAds(
    InitializeAdsEvent event,
    Emitter<InterstitialAdState> emit,
  ) async {
    final result = await initializeAdsUseCase();
    result.fold(
      (failure) => emit(
        InterstitialAdError('Initialization failed: ${failure.toString()}'),
      ),
      (_) => emit(const InterstitialAdInitialized()),
    );
  }

  Future<void> _onLoadInterstitialAd(
    LoadInterstitialAdEvent event,
    Emitter<InterstitialAdState> emit,
  ) async {
    emit(const InterstitialAdLoading());

    final result = await loadInterstitialAdUseCase(
      LoadInterstitialAdParams(adUnitId: event.adUnitId),
    );

    result.fold(
      (failure) =>
          emit(InterstitialAdError('Load failed: ${failure.toString()}')),
      (ad) {
        if (ad.state == AdState.loaded) {
          emit(InterstitialAdLoaded(ad));
        } else if (ad.state == AdState.failed) {
          emit(InterstitialAdError(ad.errorMessage ?? 'Unknown error', ad));
        }
      },
    );
  }

  Future<void> _onShowInterstitialAd(
    ShowInterstitialAdEvent event,
    Emitter<InterstitialAdState> emit,
  ) async {
    final result = await showInterstitialAdUseCase(NoParams());
    result.fold(
      (failure) =>
          emit(InterstitialAdError('Show failed: ${failure.toString()}')),
      (_) => emit(const InterstitialAdShown()),
    );
  }
}

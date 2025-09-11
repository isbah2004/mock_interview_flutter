import 'package:mock_interview/core/utils/app_logger.dart';
import 'package:mock_interview/features/ads/presentation/bloc/ad_event.dart';

import '../bloc/ad_bloc.dart';

class AdService {
  final InterstitialAdBloc _adBloc;
  bool _isInitialized = false;

  AdService(this._adBloc);

  InterstitialAdBloc get adBloc => _adBloc;

  Future<void> initialize() async {
    if (!_isInitialized) {
      AppLogger.info('AdService: initialize() called');
      _adBloc.add(const InitializeAdsEvent());
      _isInitialized = true;
      AppLogger.info('AdService: initialization event dispatched');
    }
  }

  void loadInterstitialAd(String adUnitId) {
    AppLogger.info('AdService: loadInterstitialAd(adUnitId: $adUnitId)');
    _adBloc.add(LoadInterstitialAdEvent(adUnitId));
  }

  void showInterstitialAd() {
    AppLogger.info('AdService: showInterstitialAd()');
    _adBloc.add(const ShowInterstitialAdEvent());
  }
}

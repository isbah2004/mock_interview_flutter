import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/constants/app_secrets.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ad_entity.dart';
import '../models/ad_model.dart';

abstract class AdRemoteDataSource {
  Future<void> initializeAds();
  Future<AdModel> loadInterstitialAd(String adUnitId);
  Future<void> showInterstitialAd();
  Future<void> dispose();
}

class AdMobDataSource implements AdRemoteDataSource {
  InterstitialAd? _interstitialAd;

  // Test ID for development
  String get _interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712'; // Test Ad Unit ID
  }

  String get _adUnitId {
    // Change this to _productionAdUnitId for production
    return _interstitialAdUnitId; // Use test ID for now
  }

  @override
  Future<void> initializeAds() async {
    try {
      final InitializationStatus status = await MobileAds.instance.initialize();
      AppLogger.info(
        'AdMobDataSource: MobileAds initialized: ${status.toString()}',
      );

      // Configure request settings. Include test device IDs in non-production.
      final List<String> testDevices = [];
      if (!AppSecrets.isProduction) {
        // Add the known test device id discovered from logs.
        testDevices.add('BFC06E371D2250F1040DA7AAD1258D5B');
        AppLogger.info('AdMobDataSource: adding testDeviceIds: $testDevices');
      }

      // Configure request settings
      RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: testDevices,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        maxAdContentRating: MaxAdContentRating.g,
      );

      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      AppLogger.info('AdMobDataSource: request configuration updated');
    } catch (e) {
      throw AdFailure(message: 'Failed to initialize ads: $e');
    }
  }

  @override
  Future<AdModel> loadInterstitialAd(String adUnitId) async {
    try {
      final Completer<AdModel> completer = Completer<AdModel>();

      final String usedAdUnitId = (adUnitId.isNotEmpty) ? adUnitId : _adUnitId;
      AppLogger.info(
        'AdMobDataSource: loading interstitial for adUnitId: $usedAdUnitId',
      );

      InterstitialAd.load(
        adUnitId: usedAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            AppLogger.info(
              'AdMobDataSource: interstitial loaded for $usedAdUnitId',
            );
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);

            final loadedAd = AdModel(
              adUnitId: usedAdUnitId,
              state: AdState.loaded,
              errorMessage: null,
            );

            completer.complete(loadedAd);
          },
          onAdFailedToLoad: (LoadAdError error) {
            AppLogger.warn(
              'AdMobDataSource: interstitial failed to load for $usedAdUnitId - code: ${error.code}, message: ${error.message}',
            );
            final failedAd = AdModel(
              adUnitId: usedAdUnitId,
              state: AdState.failed,
              errorMessage:
                  'Load failed: ${error.message} (Code: ${error.code})',
            );

            completer.complete(failedAd);
          },
        ),
      );

      // Timeout after 30 seconds
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          return AdModel(
            adUnitId: adUnitId,
            state: AdState.failed,
            errorMessage: 'Ad load timeout',
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'AdMobDataSource: unexpected error loading ad for $adUnitId - $e',
      );
      return AdModel(
        adUnitId: adUnitId,
        state: AdState.failed,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      throw const AdNotLoadedFailure();
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          throw AdFailure(
            message: 'Show failed: ${error.message} (Code: ${error.code})',
          );
        },
      );

      _interstitialAd!.show();
    } catch (e) {
      throw AdFailure(message: 'Failed to show ad: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

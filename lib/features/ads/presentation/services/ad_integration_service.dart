import 'package:get_it/get_it.dart';
import '../../../../core/utils/app_logger.dart';
import '../bloc/ad_bloc.dart';
import '../bloc/ad_event.dart';
import '../bloc/ad_state.dart';

class AdIntegrationService {
  final InterstitialAdBloc _adBloc;
  bool _isInitialized = false;
  DateTime? _lastAdShown;
  int _sessionInteractionCount = 0;

  // static const Duration _minAdInterval = Duration(minutes: 3);
  // static const int _interactionsBeforeAd = 3;

  AdIntegrationService(this._adBloc);

  static AdIntegrationService get instance =>
      GetIt.instance<AdIntegrationService>();

  Future<void> initialize() async {
    if (!_isInitialized) {
      AppLogger.info('AdIntegrationService: initialize');
      _adBloc.add(const InitializeAdsEvent());
      _isInitialized = true;
      AppLogger.info('AdIntegrationService: initialize event dispatched');
    }
  }

  void trackInteraction(String action) {
    _sessionInteractionCount++;
    AppLogger.debug(
      'AdIntegrationService: trackInteraction - $action ($_sessionInteractionCount)',
    );
  }

  // Future<bool> shouldShowAd() async {
  //   if (_lastAdShown != null) {
  //     final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
  //     if (timeSinceLastAd < _minAdInterval) {
  //       AppLogger.debug(
  //         'AdIntegrationService: shouldShowAd=false (too recent)',
  //       );
  //       return false;
  //     }
  //   }

  //   if (_sessionInteractionCount < _interactionsBeforeAd) {
  //     AppLogger.debug(
  //       'AdIntegrationService: shouldShowAd=false (insufficient interactions)',
  //     );
  //     return false;
  //   }

  //   AppLogger.debug('AdIntegrationService: shouldShowAd=true');
  //   return true;
  // }

  Future<void> showInterstitialAtStrategicMoment(String context) async {
    // if (!await shouldShowAd()) return;

    try {
      AppLogger.info('AdIntegrationService: start load/show for $context');

      // Request load
      const String googleTestInterstitialAdUnit =
          'ca-app-pub-1162581328240876/7157837962';
      _adBloc.add(const LoadInterstitialAdEvent(googleTestInterstitialAdUnit));
      AppLogger.debug(
        'AdIntegrationService: LoadInterstitialAdEvent dispatched for $googleTestInterstitialAdUnit',
      );

      // Wait for the bloc to emit a loaded or error state (timeout after 10s)
      final state = await adStateStream.firstWhere(
        (s) => s is InterstitialAdLoaded || s is InterstitialAdError,
      );

      if (state is InterstitialAdLoaded) {
        AppLogger.info('AdIntegrationService: ad loaded, showing for $context');
        _adBloc.add(const ShowInterstitialAdEvent());
        _lastAdShown = DateTime.now();
        _sessionInteractionCount = 0;
        AppLogger.info('AdIntegrationService: ad shown for $context');
      } else if (state is InterstitialAdError) {
        AppLogger.warn(
          'AdIntegrationService: ad failed to load - ${state.message}',
        );
      }
    } catch (_) {}
  }

  Future<void> showAfterInterviewCompletion(String interviewType) async {
    AppLogger.info(
      'AdIntegrationService: showAfterInterviewCompletion called for $interviewType',
    );
    trackInteraction('interview_completed');
    await showInterstitialAtStrategicMoment('post_interview_$interviewType');
  }

  Future<void> showBeforeInterviewStart(String interviewType) async {
    AppLogger.info(
      'AdIntegrationService: showBeforeInterviewStart called for $interviewType - tracking only',
    );
    trackInteraction('interview_setup_completed');
  }

  Future<void> showOnResultsViewing() async {
    AppLogger.info(
      'AdIntegrationService: showOnResultsViewing called - tracking only',
    );
    trackInteraction('results_viewed');
  }

  Future<void> showOnMenuNavigation() async {
    AppLogger.info(
      'AdIntegrationService: showOnMenuNavigation called - tracking only',
    );
    trackInteraction('menu_navigation');
  }

  Future<void> showOnInterviewRetry() async {
    AppLogger.info(
      'AdIntegrationService: showOnInterviewRetry called - tracking only',
    );
    trackInteraction('interview_retry');
  }

  void resetSession() {
    _sessionInteractionCount = 0;
    AppLogger.debug(
      'AdIntegrationService: resetSession - lastAdShown=$_lastAdShown',
    );
  }

  Stream<InterstitialAdState> get adStateStream => _adBloc.stream;

  Future<void> preloadAds() async {
    if (_isInitialized) {
      _adBloc.add(const LoadInterstitialAdEvent('test-ad-unit'));
    }
  }
}

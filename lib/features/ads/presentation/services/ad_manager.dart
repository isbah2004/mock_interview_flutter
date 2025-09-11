import 'package:get_storage/get_storage.dart';

class AdManager {
  static const String _completedInterviewsKey = 'completed_interviews_count';
  static const String _tabSwitchesKey = 'tab_switches_count';
  static const String _lastAdShownKey = 'last_ad_shown_timestamp';
  static const String _sessionStartKey = 'session_start_timestamp';

  static const int _minIntervalBetweenAds = 10 * 60 * 1000;
  static const int _adFrequencyInterviews = 2;
  static const int _adFrequencyNavigation = 5;

  final GetStorage _storage = GetStorage();

  void initializeSession() {
    _storage.write(_sessionStartKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool shouldShowPostInterviewAd() {
    final completedCount = _getCompletedInterviewsCount();
    final timeSinceLastAd = _getTimeSinceLastAd();

    if (completedCount % _adFrequencyInterviews == 0 &&
        timeSinceLastAd >= _minIntervalBetweenAds) {
      _updateLastAdShown();
      return true;
    }
    return false;
  }

  void incrementCompletedInterviews() {
    final currentCount = _getCompletedInterviewsCount();
    _storage.write(_completedInterviewsKey, currentCount + 1);
  }

  int _getCompletedInterviewsCount() {
    return _storage.read(_completedInterviewsKey) ?? 0;
  }

  bool shouldShowNavigationAd() {
    final switchCount = _getTabSwitchesCount();
    final timeSinceLastAd = _getTimeSinceLastAd();

    if (switchCount % _adFrequencyNavigation == 0 &&
        timeSinceLastAd >= _minIntervalBetweenAds) {
      _updateLastAdShown();
      return true;
    }
    return false;
  }

  void incrementTabSwitches() {
    final currentCount = _getTabSwitchesCount();
    _storage.write(_tabSwitchesKey, currentCount + 1);
  }

  int _getTabSwitchesCount() {
    return _storage.read(_tabSwitchesKey) ?? 0;
  }

  int _getTimeSinceLastAd() {
    final lastAdShown = _storage.read(_lastAdShownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - lastAdShown).toInt();
  }

  void _updateLastAdShown() {
    _storage.write(_lastAdShownKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool shouldShowPreInterviewAd() {
    final completedCount = _getCompletedInterviewsCount();
    final timeSinceLastAd = _getTimeSinceLastAd();

    if (completedCount > 0 &&
        completedCount % 3 == 0 &&
        timeSinceLastAd >= (_minIntervalBetweenAds * 2)) {
      _updateLastAdShown();
      return true;
    }
    return false;
  }

  bool shouldShowAuthenticationAd() {
    final sessionStart = _storage.read(_sessionStartKey) ?? 0;
    final lastAdShown = _storage.read(_lastAdShownKey) ?? 0;

    return lastAdShown < sessionStart;
  }

  void resetCounters() {
    _storage.remove(_completedInterviewsKey);
    _storage.remove(_tabSwitchesKey);
    _storage.remove(_lastAdShownKey);
  }

  Map<String, dynamic> getAdStats() {
    return {
      'completed_interviews': _getCompletedInterviewsCount(),
      'tab_switches': _getTabSwitchesCount(),
      'time_since_last_ad_minutes': _getTimeSinceLastAd() ~/ (60 * 1000),
      'session_duration_minutes': _getSessionDuration() ~/ (60 * 1000),
    };
  }

  int _getSessionDuration() {
    final sessionStart =
        _storage.read(_sessionStartKey) ??
        DateTime.now().millisecondsSinceEpoch;
    return (DateTime.now().millisecondsSinceEpoch - sessionStart).toInt();
  }
}

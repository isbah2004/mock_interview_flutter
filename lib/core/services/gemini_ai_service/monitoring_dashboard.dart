import 'package:mock_interview/core/services/gemini_ai_service/error_logger.dart';
import 'package:mock_interview/core/services/gemini_ai_service/gemini_ai_service.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

/// Comprehensive monitoring dashboard for Gemini AI services
class GeminiMonitoringDashboard {
  /// Display complete health status of all Gemini AI services
  static void displayHealthStatus() {
    AppLogger.info('');
    AppLogger.info('██████████████████████████████████████████████████████');
    AppLogger.info('██                                                  ██');
    AppLogger.info('██           GEMINI AI SERVICE HEALTH STATUS        ██');
    AppLogger.info('██                                                  ██');
    AppLogger.info('██████████████████████████████████████████████████████');
    AppLogger.info('');

    // Get comprehensive statistics
    final stats = GeminiAiService.getAllErrorStats();
    final errorSummary = GeminiErrorLogger.getRecentErrorSummary();
    final recent503Errors = GeminiErrorLogger.getRecent503Errors(limit: 5);

    // Overall Health Summary
    _displayOverallHealth(stats['overall']);

    // Service-specific Health
    _displayServiceHealth('Voice Interview Service', stats['voiceInterview']);
    _displayServiceHealth('MCQ Generation Service', stats['mcqGeneration']);
    _displayServiceHealth('MCQ Evaluation Service', stats['mcqEvaluation']);

    // Recent Error Analysis
    _displayRecentErrorAnalysis(errorSummary);

    // 503 Error Deep Dive
    _display503ErrorAnalysis(recent503Errors);

    // Recommendations
    _displayRecommendations(stats['overall'], recent503Errors);

    AppLogger.info('██████████████████████████████████████████████████████');
    AppLogger.info('██                END HEALTH STATUS                 ██');
    AppLogger.info('██████████████████████████████████████████████████████');
    AppLogger.info('');
  }

  static void _displayOverallHealth(Map<String, dynamic> overallStats) {
    AppLogger.info('🏥 OVERALL SERVICE HEALTH');
    AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final totalCalls = overallStats['totalApiCalls'] as int;
    final total503 = overallStats['total503Errors'] as int;
    final errorRate = overallStats['errorRate503'] as double;
    final retrySuccessRate = overallStats['retrySuccessRate'] as double;

    // Health indicators
    String healthStatus = 'EXCELLENT';
    String healthEmoji = '🟢';

    if (errorRate > 20) {
      healthStatus = 'CRITICAL';
      healthEmoji = '🔴';
    } else if (errorRate > 10) {
      healthStatus = 'WARNING';
      healthEmoji = '🟡';
    } else if (errorRate > 5) {
      healthStatus = 'FAIR';
      healthEmoji = '🟠';
    }

    AppLogger.info('$healthEmoji Service Status: $healthStatus');
    AppLogger.info('📊 Total API Calls: $totalCalls');
    AppLogger.info('❌ Total 503 Errors: $total503');
    AppLogger.info('📈 503 Error Rate: ${errorRate.toStringAsFixed(2)}%');
    AppLogger.info(
      '🔄 Retry Success Rate: ${retrySuccessRate.toStringAsFixed(2)}%',
    );
    AppLogger.info('');
  }

  static void _displayServiceHealth(
    String serviceName,
    Map<String, dynamic> serviceStats,
  ) {
    AppLogger.info('🔧 $serviceName');
    AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final calls = serviceStats['totalApiCalls'] as int;
    final errors = serviceStats['total503Errors'] as int;
    final retries = serviceStats['successfulRetries'] as int;
    final errorRate = serviceStats['errorRate503'] as double;

    String status = '🟢 HEALTHY';
    if (errorRate > 15) {
      status = '🔴 UNHEALTHY';
    } else if (errorRate > 8) {
      status = '🟡 DEGRADED';
    }

    AppLogger.info('$status (${errorRate.toStringAsFixed(1)}% error rate)');
    AppLogger.info('  📞 API Calls: $calls');
    AppLogger.info('  ❌ 503 Errors: $errors');
    AppLogger.info('  ✅ Successful Retries: $retries');
    AppLogger.info('');
  }

  static void _displayRecentErrorAnalysis(
    List<Map<String, dynamic>> errorSummary,
  ) {
    AppLogger.info('🔍 RECENT ERROR ANALYSIS (Last 50 calls)');
    AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (errorSummary.isEmpty) {
      AppLogger.info('✅ No recent errors detected');
    } else {
      for (final error in errorSummary.take(5)) {
        final type = error['errorType'] as String;
        final count = error['count'] as int;
        final emoji = _getErrorEmoji(type);
        AppLogger.info('  $emoji $type: $count occurrences');
      }
    }
    AppLogger.info('');
  }

  static void _display503ErrorAnalysis(
    List<Map<String, dynamic>> recent503Errors,
  ) {
    AppLogger.info('🚨 503 ERROR DEEP DIVE (Last 5 occurrences)');
    AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (recent503Errors.isEmpty) {
      AppLogger.info('✅ No recent 503 errors detected');
    } else {
      for (int i = 0; i < recent503Errors.length; i++) {
        final error = recent503Errors[i];
        AppLogger.info('  ${i + 1}. ${error['timestamp']}');
        AppLogger.info('     Service: ${error['service']}');
        AppLogger.info('     Operation: ${error['operation']}');
        if (error['context'] != null && (error['context'] as Map).isNotEmpty) {
          AppLogger.info('     Context: ${error['context']}');
        }
        AppLogger.info('');
      }
    }
    AppLogger.info('');
  }

  static void _displayRecommendations(
    Map<String, dynamic> overallStats,
    List<Map<String, dynamic>> recent503Errors,
  ) {
    AppLogger.info('💡 RECOMMENDATIONS');
    AppLogger.info('━━━━━━━━━━━━━━━━━━━━');

    final errorRate = overallStats['errorRate503'] as double;
    final retrySuccessRate = overallStats['retrySuccessRate'] as double;
    final totalCalls = overallStats['totalApiCalls'] as int;

    if (errorRate > 20) {
      AppLogger.info('🔴 CRITICAL: High 503 error rate detected!');
      AppLogger.info('   • Gemini API may be experiencing major outages');
      AppLogger.info('   • Consider implementing circuit breaker pattern');
      AppLogger.info('   • Monitor Google Cloud Status page');
      AppLogger.info('   • Consider fallback AI service');
    } else if (errorRate > 10) {
      AppLogger.info('🟡 WARNING: Elevated 503 error rate');
      AppLogger.info('   • Increase retry delays between attempts');
      AppLogger.info('   • Implement exponential backoff with jitter');
      AppLogger.info('   • Monitor API quota usage');
    } else if (errorRate > 5) {
      AppLogger.info('🟠 CAUTION: Moderate 503 error rate');
      AppLogger.info('   • Current retry strategy appears effective');
      AppLogger.info(
        '   • Consider slight delay increases if pattern continues',
      );
    } else {
      AppLogger.info('✅ Service is performing well');
      AppLogger.info('   • Continue current error handling approach');
      AppLogger.info('   • Monitor for any emerging patterns');
    }

    if (retrySuccessRate < 50 && recent503Errors.isNotEmpty) {
      AppLogger.info('');
      AppLogger.info('🔄 RETRY STRATEGY RECOMMENDATIONS:');
      AppLogger.info(
        '   • Current retry success rate is low (${retrySuccessRate.toStringAsFixed(1)}%)',
      );
      AppLogger.info('   • Consider increasing base delay from 2s to 5s');
      AppLogger.info('   • Implement jitter in exponential backoff');
      AppLogger.info('   • Add circuit breaker after consecutive failures');
    }

    if (totalCalls > 0) {
      AppLogger.info('');
      AppLogger.info('📊 MONITORING RECOMMENDATIONS:');
      AppLogger.info('   • Continue logging all API interactions');
      AppLogger.info('   • Set up alerts for error rates > 15%');
      AppLogger.info('   • Review logs every hour during peak usage');
      AppLogger.info('   • Export error logs for trend analysis');
    }

    AppLogger.info('');
  }

  static String _getErrorEmoji(String errorType) {
    switch (errorType) {
      case '503_SERVICE_UNAVAILABLE':
        return '🚫';
      case '429_RATE_LIMIT':
        return '⏱️';
      case '401_UNAUTHORIZED':
        return '🔐';
      case '400_BAD_REQUEST':
        return '❌';
      case 'TIMEOUT':
        return '⏰';
      case 'NETWORK_ERROR':
        return '🌐';
      case 'CONNECTION_ERROR':
        return '🔌';
      default:
        return '❓';
    }
  }

  /// Quick health check - returns a simple status
  static Map<String, dynamic> quickHealthCheck() {
    final stats = GeminiAiService.getAllErrorStats();
    final errorRate = stats['overall']['errorRate503'] as double;

    String status = 'HEALTHY';
    if (errorRate > 20) {
      status = 'CRITICAL';
    } else if (errorRate > 10) {
      status = 'DEGRADED';
    } else if (errorRate > 5) {
      status = 'WARNING';
    }

    return {
      'status': status,
      'errorRate': errorRate,
      'totalCalls': stats['overall']['totalApiCalls'],
      'total503Errors': stats['overall']['total503Errors'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Export comprehensive report for debugging
  static String generateComprehensiveReport() {
    final buffer = StringBuffer();
    final timestamp = DateTime.now().toIso8601String();

    buffer.writeln('GEMINI AI SERVICE COMPREHENSIVE REPORT');
    buffer.writeln('Generated: $timestamp');
    buffer.writeln('=' * 60);
    buffer.writeln('');

    // Add all statistics
    final stats = GeminiAiService.getAllErrorStats();
    buffer.writeln('OVERALL STATISTICS:');
    buffer.writeln('Total API Calls: ${stats['overall']['totalApiCalls']}');
    buffer.writeln('Total 503 Errors: ${stats['overall']['total503Errors']}');
    buffer.writeln(
      'Error Rate: ${stats['overall']['errorRate503'].toStringAsFixed(2)}%',
    );
    buffer.writeln(
      'Retry Success Rate: ${stats['overall']['retrySuccessRate'].toStringAsFixed(2)}%',
    );
    buffer.writeln('');

    // Add service breakdown
    buffer.writeln('SERVICE BREAKDOWN:');
    for (final service in [
      'voiceInterview',
      'mcqGeneration',
      'mcqEvaluation',
    ]) {
      final serviceStats = stats[service] as Map<String, dynamic>;
      buffer.writeln('$service:');
      buffer.writeln('  API Calls: ${serviceStats['totalApiCalls']}');
      buffer.writeln('  503 Errors: ${serviceStats['total503Errors']}');
      buffer.writeln(
        '  Error Rate: ${serviceStats['errorRate503'].toStringAsFixed(2)}%',
      );
      buffer.writeln('');
    }

    // Add recent errors
    final recent503 = GeminiErrorLogger.getRecent503Errors(limit: 10);
    buffer.writeln('RECENT 503 ERRORS:');
    for (final error in recent503) {
      buffer.writeln(
        '- ${error['timestamp']}: ${error['service']} ${error['operation']}',
      );
    }

    buffer.writeln('');
    buffer.writeln('=' * 60);
    buffer.writeln('END REPORT');

    return buffer.toString();
  }

  /// Auto-trigger alerts based on error thresholds
  static void checkAndTriggerAlerts() {
    final healthCheck = quickHealthCheck();
    final status = healthCheck['status'] as String;
    final errorRate = healthCheck['errorRate'] as double;

    if (status == 'CRITICAL') {
      AppLogger.error('🚨🚨🚨 CRITICAL ALERT 🚨🚨🚨');
      AppLogger.error(
        'Gemini AI Service Error Rate: ${errorRate.toStringAsFixed(2)}%',
      );
      AppLogger.error('Immediate attention required!');
      AppLogger.error(
        'Consider implementing circuit breaker or fallback service',
      );
      AppLogger.error('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
    } else if (status == 'DEGRADED') {
      AppLogger.warn('⚠️ WARNING ALERT ⚠️');
      AppLogger.warn(
        'Gemini AI Service Error Rate: ${errorRate.toStringAsFixed(2)}%',
      );
      AppLogger.warn('Monitor closely and consider adjusting retry strategy');
      AppLogger.warn('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️');
    }
  }
}

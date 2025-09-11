import 'dart:io';
import 'package:mock_interview/core/services/gemini_ai_service/gemini_ai_service.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

/// Centralized error logging utility for Gemini AI services
class GeminiErrorLogger {
  static final List<Map<String, dynamic>> _persistentErrorLog = [];
  static const int maxLogEntries = 200;

  /// Log a detailed error with context
  static void logError({
    required String service,
    required String operation,
    required String error,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'service': service,
      'operation': operation,
      'error': error,
      'context': context ?? {},
      'stackTrace': stackTrace,
      'is503Error': _is503Error(error),
      'errorType': _categorizeError(error),
    };

    _persistentErrorLog.add(logEntry);

    // Keep only recent entries to prevent memory issues
    if (_persistentErrorLog.length > maxLogEntries) {
      _persistentErrorLog.removeAt(0);
    }

    // Print detailed error information
    _printDetailedError(logEntry);

    // Log comprehensive statistics after each error
    _logComprehensiveStats();
  }

  /// Check if error is a 503 Service Unavailable error
  static bool _is503Error(String error) {
    final errorLower = error.toLowerCase();
    return errorLower.contains('503') ||
        errorLower.contains('service unavailable') ||
        errorLower.contains('temporarily unavailable');
  }

  /// Categorize error type for better analysis
  static String _categorizeError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('503')) return '503_SERVICE_UNAVAILABLE';
    if (errorLower.contains('429')) return '429_RATE_LIMIT';
    if (errorLower.contains('401')) return '401_UNAUTHORIZED';
    if (errorLower.contains('400')) return '400_BAD_REQUEST';
    if (errorLower.contains('timeout')) return 'TIMEOUT';
    if (errorLower.contains('network')) return 'NETWORK_ERROR';
    if (errorLower.contains('connection')) return 'CONNECTION_ERROR';

    return 'UNKNOWN_ERROR';
  }

  /// Print detailed error information
  static void _printDetailedError(Map<String, dynamic> logEntry) {
    AppLogger.info('');
    AppLogger.info('=== GEMINI AI ERROR LOG ===');
    AppLogger.info('Timestamp: ${logEntry['timestamp']}');
    AppLogger.info('Service: ${logEntry['service']}');
    AppLogger.info('Operation: ${logEntry['operation']}');
    AppLogger.info('Error Type: ${logEntry['errorType']}');
    AppLogger.info('Is 503 Error: ${logEntry['is503Error']}');
    AppLogger.info('Error: ${logEntry['error']}');

    if (logEntry['context'] != null &&
        (logEntry['context'] as Map).isNotEmpty) {
      AppLogger.info('Context: ${logEntry['context']}');
    }

    if (logEntry['stackTrace'] != null) {
      AppLogger.info('Stack Trace: ${logEntry['stackTrace']}');
    }

    AppLogger.info('=== END ERROR LOG ===');
    AppLogger.info('');
  }

  /// Log comprehensive statistics from all services
  static void _logComprehensiveStats() {
    try {
      final stats = GeminiAiService.getAllErrorStats();

      AppLogger.info('');
      AppLogger.info('=== GEMINI AI COMPREHENSIVE ERROR STATISTICS ===');
      AppLogger.info('Overall Performance:');
      AppLogger.info('  Total API Calls: ${stats['overall']['totalApiCalls']}');
      AppLogger.info(
        '  Total 503 Errors: ${stats['overall']['total503Errors']}',
      );
      AppLogger.info(
        '  Successful Retries: ${stats['overall']['successfulRetries']}',
      );
      AppLogger.info(
        '  503 Error Rate: ${stats['overall']['errorRate503'].toStringAsFixed(2)}%',
      );
      AppLogger.info(
        '  Retry Success Rate: ${stats['overall']['retrySuccessRate'].toStringAsFixed(2)}%',
      );

      AppLogger.info('');
      AppLogger.info('Service Breakdown:');
      AppLogger.info(
        '  Voice Interview: ${stats['voiceInterview']['totalApiCalls']} calls, ${stats['voiceInterview']['total503Errors']} 503 errors',
      );
      AppLogger.info(
        '  MCQ Generation: ${stats['mcqGeneration']['totalApiCalls']} calls, ${stats['mcqGeneration']['total503Errors']} 503 errors',
      );
      AppLogger.info(
        '  MCQ Evaluation: ${stats['mcqEvaluation']['totalApiCalls']} calls, ${stats['mcqEvaluation']['total503Errors']} 503 errors',
      );

      AppLogger.info('');
      AppLogger.info('Recent Error Summary:');
      final recentErrors = getRecentErrorSummary();
      for (final errorSummary in recentErrors) {
        AppLogger.info(
          '  ${errorSummary['errorType']}: ${errorSummary['count']} occurrences',
        );
      }

      AppLogger.info('=== END COMPREHENSIVE STATISTICS ===');
      AppLogger.info('');
    } catch (e) {
      AppLogger.error('Error logging comprehensive stats: $e');
    }
  }

  /// Get recent error summary grouped by error type
  static List<Map<String, dynamic>> getRecentErrorSummary() {
    final errorCounts = <String, int>{};

    // Count errors from the last 50 entries
    final recentEntries = _persistentErrorLog.take(50);
    for (final entry in recentEntries) {
      final errorType = entry['errorType'] as String;
      errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;
    }

    return errorCounts.entries
        .map((entry) => {'errorType': entry.key, 'count': entry.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  /// Get all logged errors for analysis
  static List<Map<String, dynamic>> getAllErrors() {
    return List.from(_persistentErrorLog);
  }

  /// Get recent 503 errors specifically
  static List<Map<String, dynamic>> getRecent503Errors({int limit = 10}) {
    return _persistentErrorLog
        .where((entry) => entry['is503Error'] == true)
        .take(limit)
        .toList();
  }

  /// Get error statistics by service
  static Map<String, dynamic> getErrorStatsByService() {
    final serviceStats = <String, Map<String, int>>{};

    for (final entry in _persistentErrorLog) {
      final service = entry['service'] as String;
      final errorType = entry['errorType'] as String;

      serviceStats[service] ??= <String, int>{};
      serviceStats[service]![errorType] =
          (serviceStats[service]![errorType] ?? 0) + 1;
    }

    return serviceStats;
  }

  /// Clear all logged errors (for testing or maintenance)
  static void clearErrorLog() {
    _persistentErrorLog.clear();
    AppLogger.info('GeminiErrorLogger: Error log cleared');
  }

  /// Export error log to string for debugging
  static String exportErrorLog() {
    final buffer = StringBuffer();
    buffer.writeln('=== GEMINI AI ERROR LOG EXPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Entries: ${_persistentErrorLog.length}');
    buffer.writeln('');

    for (final entry in _persistentErrorLog) {
      buffer.writeln('--- Error Entry ---');
      buffer.writeln('Timestamp: ${entry['timestamp']}');
      buffer.writeln('Service: ${entry['service']}');
      buffer.writeln('Operation: ${entry['operation']}');
      buffer.writeln('Error Type: ${entry['errorType']}');
      buffer.writeln('Error: ${entry['error']}');
      if (entry['context'] != null && (entry['context'] as Map).isNotEmpty) {
        buffer.writeln('Context: ${entry['context']}');
      }
      buffer.writeln('');
    }

    buffer.writeln('=== END ERROR LOG EXPORT ===');
    return buffer.toString();
  }

  /// Save error log to file (if file system is available)
  static Future<void> saveErrorLogToFile([String? filePath]) async {
    try {
      final path =
          filePath ??
          '/tmp/gemini_error_log_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(path);
      await file.writeAsString(exportErrorLog());
      AppLogger.info('GeminiErrorLogger: Error log saved to $path');
    } catch (e) {
      AppLogger.error(
        'GeminiErrorLogger: Failed to save error log to file: $e',
      );
    }
  }
}

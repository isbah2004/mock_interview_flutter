import 'package:dio/dio.dart';
import 'package:mock_interview/core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/websocket_service.dart';
import '../models/interview_request_model.dart';
import '../models/interview_response_model.dart';
import '../models/session_stats_model.dart';

abstract class InterviewRemoteDataSource {
  Future<InterviewResponseModel> startMcqInterview(
    InterviewRequestModel request,
  );
  Future<InterviewResponseModel> submitMcqAnswer(InterviewRequestModel request);
  Stream<InterviewResponseModel> startVoiceInterview(
    InterviewRequestModel request,
  );
  Future<void> submitVoiceAnswer(InterviewRequestModel request);
  Future<void> endVoiceInterview(String sessionId);
  Future<SessionStatsModel> getSessionStats(String sessionId);
  Future<void> deleteSession(String sessionId);
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
   final ApiService apiService;
  final WebSocketClient webSocketClient;

  InterviewRemoteDataSourceImpl({
    required this.apiService,
    required this.webSocketClient,
  });

  @override
  Future<InterviewResponseModel> startMcqInterview(
    InterviewRequestModel request,
  ) async {
    try {
      final response = await apiService.dio.post(
        ApiConstants.startInterview,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return InterviewResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['detail'] ?? 'Unknown error');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  @override
  Future<InterviewResponseModel> submitMcqAnswer(
    InterviewRequestModel request,
  ) async {
    try {
      final response = await apiService.dio.post(
        ApiConstants.submitResponse,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return InterviewResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['detail'] ?? 'Unknown error');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  @override
  Stream<InterviewResponseModel> startVoiceInterview(
    InterviewRequestModel request,
  ) {
    return webSocketClient.connect(ApiConstants.voiceInterview).map((data) {
      switch (data['type']) {
        case 'question':
        case 'response':
          return InterviewResponseModel.fromJson(data['data']);
        case 'error':
          throw ServerException(data['data']['detail']);
        default:
          throw ServerException('Unknown message type: ${data['type']}');
      }
    });
  }

  @override
  Future<void> submitVoiceAnswer(InterviewRequestModel request) async {
    webSocketClient.send({'type': 'answer', 'data': request.toJson()});
  }

  @override
  Future<void> endVoiceInterview(String sessionId) async {
    webSocketClient.send({
      'type': 'end',
      'data': {'reason': 'user_ended'},
    });
    webSocketClient.close();
  }

  @override
  Future<SessionStatsModel> getSessionStats(String sessionId) async {
    try {
      final response = await apiService.dio.get('${ApiConstants.sessionStats}/$sessionId');

      if (response.statusCode == 200) {
        return SessionStatsModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['detail'] ?? 'Unknown error');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await apiService.dio.delete(
        '${ApiConstants.deleteSession}/$sessionId',
      );

      if (response.statusCode != 200) {
        throw ServerException(response.data['detail'] ?? 'Unknown error');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return e.response?.data['detail'] ?? 'Server error occurred.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error occurred. Please try again.';
    }
  }
}

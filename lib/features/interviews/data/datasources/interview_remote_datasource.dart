// import 'package:dio/dio.dart';
// import 'package:mock_interview/core/services/api_service.dart';
// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/errors/exceptions.dart';
// import '../../../../core/services/websocket_service.dart';
// import '../models/interview_request_model.dart';
// import '../models/interview_response_model.dart';
// import '../models/session_stats_model.dart';

// abstract class InterviewRemoteDataSource {
//   Future<InterviewResponseModel> startMcqInterview(
//     InterviewRequestModel request,
//   );
//   Future<InterviewResponseModel> submitMcqAnswer(InterviewRequestModel request);
//   Stream<InterviewResponseModel> startVoiceInterview(
//     InterviewRequestModel request,
//   );
//   Future<void> submitVoiceAnswer(InterviewRequestModel request);
//   Future<void> endVoiceInterview(String sessionId);
//   Future<SessionStatsModel> getSessionStats(String sessionId);
//   Future<void> deleteSession(String sessionId);
// }

// class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
//    final ApiService apiService;
//   final WebSocketClient webSocketClient;

//   InterviewRemoteDataSourceImpl({
//     required this.apiService,
//     required this.webSocketClient,
//   });

//   @override
//   Future<InterviewResponseModel> startMcqInterview(
//     InterviewRequestModel request,
//   ) async {
//     try {
//       final response = await apiService.dio.post(
//         ApiConstants.startInterview,
//         data: request.toJson(),
//       );

//       if (response.statusCode == 200) {
//         return InterviewResponseModel.fromJson(response.data);
//       } else {
//         throw ServerException(response.data['detail'] ?? 'Unknown error');
//       }
//     } on DioException catch (e) {
//       throw ServerException(_handleDioError(e));
//     }
//   }

//   @override
//   Future<InterviewResponseModel> submitMcqAnswer(
//     InterviewRequestModel request,
//   ) async {
//     try {
//       final response = await apiService.dio.post(
//         ApiConstants.submitResponse,
//         data: request.toJson(),
//       );

//       if (response.statusCode == 200) {
//         return InterviewResponseModel.fromJson(response.data);
//       } else {
//         throw ServerException(response.data['detail'] ?? 'Unknown error');
//       }
//     } on DioException catch (e) {
//       throw ServerException(_handleDioError(e));
//     }
//   }

//   @override
//   Stream<InterviewResponseModel> startVoiceInterview(
//     InterviewRequestModel request,
//   ) {
//     return webSocketClient.connect(ApiConstants.voiceInterview).map((data) {
//       switch (data['type']) {
//         case 'question':
//         case 'response':
//           return InterviewResponseModel.fromJson(data['data']);
//         case 'error':
//           throw ServerException(data['data']['detail']);
//         default:
//           throw ServerException('Unknown message type: ${data['type']}');
//       }
//     });
//   }

//   @override
//   Future<void> submitVoiceAnswer(InterviewRequestModel request) async {
//     webSocketClient.send({'type': 'answer', 'data': request.toJson()});
//   }

//   @override
//   Future<void> endVoiceInterview(String sessionId) async {
//     webSocketClient.send({
//       'type': 'end',
//       'data': {'reason': 'user_ended'},
//     });
//     webSocketClient.close();
//   }

//   @override
//   Future<SessionStatsModel> getSessionStats(String sessionId) async {
//     try {
//       final response = await apiService.dio.get('${ApiConstants.sessionStats}/$sessionId');

//       if (response.statusCode == 200) {
//         return SessionStatsModel.fromJson(response.data);
//       } else {
//         throw ServerException(response.data['detail'] ?? 'Unknown error');
//       }
//     } on DioException catch (e) {
//       throw ServerException(_handleDioError(e));
//     }
//   }

//   @override
//   Future<void> deleteSession(String sessionId) async {
//     try {
//       final response = await apiService.dio.delete(
//         '${ApiConstants.deleteSession}/$sessionId',
//       );

//       if (response.statusCode != 200) {
//         throw ServerException(response.data['detail'] ?? 'Unknown error');
//       }
//     } on DioException catch (e) {
//       throw ServerException(_handleDioError(e));
//     }
//   }

//   String _handleDioError(DioException e) {
//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return 'Connection timeout. Please check your internet connection.';
//       case DioExceptionType.badResponse:
//         return e.response?.data['detail'] ?? 'Server error occurred.';
//       case DioExceptionType.cancel:
//         return 'Request was cancelled.';
//       default:
//         return 'Network error occurred. Please try again.';
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:mock_interview/core/constants/api_constants.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/api_service.dart';
import '../models/interview_model.dart';
import '../models/evaluation_result_model.dart';
import '../models/interview_request_model.dart';

abstract class InterviewRemoteDataSource {
  Future<InterviewModel> startInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required int numQuestions,
    required QuestionCategory category,
  });

  Future<EvaluationResultModel> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  });

  Future<Map<String, dynamic>> getSessionStats(String sessionId);
  Future<void> deleteSession(String sessionId);
  Future<Map<String, dynamic>> getActiveSessions();
  Future<bool> checkHealth();
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final ApiService _apiService;

  InterviewRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<InterviewModel> startInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required int numQuestions,
    required QuestionCategory category,
  }) async {
 
    try {
      final request = InterviewRequestModel(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        numQuestions: numQuestions,
        category: category,
      );
      final response = await _apiService.dio.post(
        ApiConstants.startInterview,
        data: request.toJson(),
      );

      return InterviewModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to start interview');
    } catch (e) {
      throw ServerFailure('Failed to start interview: $e');
    }
  }

  @override
  Future<EvaluationResultModel> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  }) async {
    try {
      final request = InterviewRequestModel(
        userId: userId,
        jobRole: '', // Not needed for submission
        difficultyLevel: DifficultyLevel.easy, // Not needed for submission
        numQuestions: answers.length,
        category: QuestionCategory.behavioral, // Not needed for submission
        questionId: sessionId,
        answers: answers,
      );
      final response = await _apiService.dio.post(
        ApiConstants.submitResponse,
        data: request.toJson(),
      );

      return EvaluationResultModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to submit answers');
    } catch (e) {
      throw ServerFailure('Failed to submit answers: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.sessionStats}/$sessionId',
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to retrieve stats');
    } catch (e) {
     throw ServerFailure('Failed to retrieve stats: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
try {
 await _apiService.dio.delete(
    '${ApiConstants.deleteSession}/$sessionId',
  );
  
}
on DioException catch (e) {
    throw ServerFailure(e.message ?? 'Failed to delete session');
  }

 catch (e) {
    throw ServerFailure('Failed to delete session: $e');
  }


  
}

@override
Future<Map<String, dynamic>> getActiveSessions() async {
  try {
    final response = await _apiService.dio.get(ApiConstants.activeSessions);
    return response.data;
  } on DioException catch (e) {
    throw ServerFailure(e.message ?? 'Failed to retrieve active sessions');
  } catch (e) {
    throw ServerFailure('Failed to retrieve active sessions: $e');
  }
}

@override
Future<bool> checkHealth() async {
  try {
    final response = await _apiService.dio.get(ApiConstants.healthCheck);
    return response.data['status'] == 'ok';
  } on DioException catch (e) {
    throw ServerFailure(e.message ?? 'Health check failed');
  } catch (e) {
    throw ServerFailure('Health check failed: $e');
  }
}

}
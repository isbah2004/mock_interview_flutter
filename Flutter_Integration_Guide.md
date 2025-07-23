# Flutter Integration Guide for AI Interview Agent

## Overview

This guide helps you integrate the FastAPI AI Interview Agent with your Flutter app using Clean Architecture, SOLID principles, BLoC pattern, and Appwrite for authentication and data persistence.

## Architecture Overview

```
Flutter App (Clean Architecture)
├── Presentation Layer (BLoC + UI)
├── Domain Layer (Entities + Use Cases)
├── Data Layer (Repositories + Data Sources)
│   ├── Remote Data Source (AI Agent API)
│   └── Local Data Source (Appwrite)
└── Core (Dependencies + Utilities)
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── network_info.dart
│   │   └── api_client.dart
│   └── utils/
│       ├── websocket_client.dart
│       └── timer_service.dart
├── features/
│   └── interview/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── interview_remote_datasource.dart
│       │   │   └── interview_local_datasource.dart
│       │   ├── models/
│       │   │   ├── interview_request_model.dart
│       │   │   ├── interview_response_model.dart
│       │   │   └── session_stats_model.dart
│       │   └── repositories/
│       │       └── interview_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── interview_session.dart
│       │   │   ├── question.dart
│       │   │   └── session_stats.dart
│       │   ├── repositories/
│       │   │   └── interview_repository.dart
│       │   └── usecases/
│       │       ├── start_mcq_interview.dart
│       │       ├── submit_mcq_answer.dart
│       │       ├── start_voice_interview.dart
│       │       ├── submit_voice_answer.dart
│       │       └── get_session_stats.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── mcq_interview/
│           │   │   ├── mcq_interview_bloc.dart
│           │   │   ├── mcq_interview_event.dart
│           │   │   └── mcq_interview_state.dart
│           │   └── voice_interview/
│           │       ├── voice_interview_bloc.dart
│           │       ├── voice_interview_event.dart
│           │       └── voice_interview_state.dart
│           ├── pages/
│           │   ├── interview_setup_page.dart
│           │   ├── mcq_interview_page.dart
│           │   └── voice_interview_page.dart
│           └── widgets/
│               ├── question_card.dart
│               ├── timer_widget.dart
│               └── score_widget.dart
└── main.dart
```

## 1. Core Setup

### API Constants

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://your-api-domain.com';
  static const String wsBaseUrl = 'ws://your-api-domain.com';

  // MCQ Endpoints
  static const String startInterview = '/api/v1/interview/start_interview';
  static const String submitResponse = '/api/v1/interview/submit_response';
  static const String sessionStats = '/api/v1/interview/session_stats';
  static const String deleteSession = '/api/v1/interview/session';

  // WebSocket Endpoints
  static const String voiceInterview = '/ws/voice_interview';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### Network Info

```dart
// lib/core/network/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

### API Client

```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.headers,
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  Dio get dio => _dio;
}
```

### WebSocket Client

```dart
// lib/core/utils/websocket_client.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> connect(String endpoint) {
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${ApiConstants.wsBaseUrl}$endpoint'),
      );

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message as String);
          _controller!.add(data);
        },
        onError: (error) {
          _controller!.addError(error);
        },
        onDone: () {
          _controller!.close();
        },
      );
    } catch (e) {
      _controller!.addError(e);
    }

    return _controller!.stream;
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void close() {
    _channel?.sink.close();
    _controller?.close();
  }
}
```

### Timer Service

```dart
// lib/core/utils/timer_service.dart
import 'dart:async';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  final StreamController<int> _timerController = StreamController<int>.broadcast();

  Stream<int> get timerStream => _timerController.stream;
  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _timer?.isActive ?? false;

  void startTimer(int durationMinutes) {
    _remainingSeconds = durationMinutes * 60;
    _timerController.add(_remainingSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _timerController.add(0);
      } else {
        _remainingSeconds--;
        _timerController.add(_remainingSeconds);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _timerController.add(0);
        } else {
          _remainingSeconds--;
          _timerController.add(_remainingSeconds);
        }
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _remainingSeconds = 0;
    _timerController.add(0);
  }

  void dispose() {
    _timer?.cancel();
    _timerController.close();
  }

  String formatTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

## 2. Domain Layer

### Entities

```dart
// lib/features/interview/domain/entities/interview_session.dart
import 'package:equatable/equatable.dart';

enum DifficultyLevel { easy, medium, hard }
enum QuestionCategory { general, technical, behavioral, industry_specific }
enum InterviewType { mcq, voice }

class InterviewSession extends Equatable {
  final String sessionId;
  final String userId;
  final String jobRole;
  final InterviewType interviewType;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int? numQuestions; // Only for MCQ
  final DateTime createdAt;
  final bool isComplete;

  const InterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.category,
    this.numQuestions,
    required this.createdAt,
    this.isComplete = false,
  });

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    jobRole,
    interviewType,
    difficultyLevel,
    category,
    numQuestions,
    createdAt,
    isComplete,
  ];
}
```

```dart
// lib/features/interview/domain/entities/question.dart
import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String questionText;
  final List<String>? options; // Only for MCQ
  final String? feedback;
  final double? score;
  final int? currentQuestionNumber;
  final int? totalQuestions;

  const Question({
    required this.questionText,
    this.options,
    this.feedback,
    this.score,
    this.currentQuestionNumber,
    this.totalQuestions,
  });

  @override
  List<Object?> get props => [
    questionText,
    options,
    feedback,
    score,
    currentQuestionNumber,
    totalQuestions,
  ];
}
```

### Repository Interface

```dart
// lib/features/interview/domain/repositories/interview_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/interview_session.dart';
import '../entities/question.dart';
import '../entities/session_stats.dart';

abstract class InterviewRepository {
  // MCQ Methods
  Future<Either<Failure, Question>> startMcqInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    required int numQuestions,
  });

  Future<Either<Failure, Question>> submitMcqAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  });

  // Voice Methods
  Stream<Either<Failure, Question>> startVoiceInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
  });

  Future<Either<Failure, void>> submitVoiceAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  });

  Future<Either<Failure, void>> endVoiceInterview(String sessionId);

  // Common Methods
  Future<Either<Failure, SessionStats>> getSessionStats(String sessionId);
  Future<Either<Failure, void>> deleteSession(String sessionId);

  // Appwrite Integration
  Future<Either<Failure, void>> saveSessionToAppwrite(InterviewSession session);
  Future<Either<Failure, List<InterviewSession>>> getUserSessions(String userId);
}
```

### Use Cases

```dart
// lib/features/interview/domain/usecases/start_mcq_interview.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/interview_session.dart';
import '../entities/question.dart';
import '../repositories/interview_repository.dart';

class StartMcqInterview implements UseCase<Question, StartMcqInterviewParams> {
  final InterviewRepository repository;

  StartMcqInterview(this.repository);

  @override
  Future<Either<Failure, Question>> call(StartMcqInterviewParams params) async {
    return await repository.startMcqInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category,
      numQuestions: params.numQuestions,
    );
  }
}

class StartMcqInterviewParams extends Equatable {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int numQuestions;

  const StartMcqInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
    required this.numQuestions,
  });

  @override
  List<Object> get props => [userId, jobRole, difficultyLevel, category, numQuestions];
}
```

## 3. Data Layer

### Models

```dart
// lib/features/interview/data/models/interview_request_model.dart
import '../../domain/entities/interview_session.dart';

class InterviewRequestModel {
  final String userId;
  final String jobRole;
  final String interviewType;
  final String difficultyLevel;
  final String category;
  final int? numQuestions;
  final String? answer;
  final String? questionId;

  InterviewRequestModel({
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.category,
    this.numQuestions,
    this.answer,
    this.questionId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel,
      'category': category,
    };

    if (numQuestions != null) json['num_questions'] = numQuestions;
    if (answer != null) json['answer'] = answer;
    if (questionId != null) json['question_id'] = questionId;

    return json;
  }

  factory InterviewRequestModel.fromMcqParams({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    required int numQuestions,
    String? answer,
    String? questionId,
  }) {
    return InterviewRequestModel(
      userId: userId,
      jobRole: jobRole,
      interviewType: 'mcq',
      difficultyLevel: difficultyLevel.name,
      category: category.name,
      numQuestions: numQuestions,
      answer: answer,
      questionId: questionId,
    );
  }

  factory InterviewRequestModel.fromVoiceParams({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    String? answer,
    String? questionId,
  }) {
    return InterviewRequestModel(
      userId: userId,
      jobRole: jobRole,
      interviewType: 'voice',
      difficultyLevel: difficultyLevel.name,
      category: category.name,
      answer: answer,
      questionId: questionId,
    );
  }
}
```

```dart
// lib/features/interview/data/models/interview_response_model.dart
import '../../domain/entities/question.dart';

class InterviewResponseModel extends Question {
  final String? questionId;
  final bool? sessionComplete;
  final double? finalScore;

  const InterviewResponseModel({
    required String questionText,
    List<String>? options,
    String? feedback,
    double? score,
    int? currentQuestionNumber,
    int? totalQuestions,
    this.questionId,
    this.sessionComplete,
    this.finalScore,
  }) : super(
    questionText: questionText,
    options: options,
    feedback: feedback,
    score: score,
    currentQuestionNumber: currentQuestionNumber,
    totalQuestions: totalQuestions,
  );

  factory InterviewResponseModel.fromJson(Map<String, dynamic> json) {
    return InterviewResponseModel(
      questionText: json['question'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      feedback: json['feedback'],
      score: json['score']?.toDouble(),
      currentQuestionNumber: json['current_question_number'],
      totalQuestions: json['total_questions'],
      questionId: json['question_id'],
      sessionComplete: json['session_complete'],
      finalScore: json['final_score']?.toDouble(),
    );
  }

  Question toEntity() {
    return Question(
      questionText: questionText,
      options: options,
      feedback: feedback,
      score: score,
      currentQuestionNumber: currentQuestionNumber,
      totalQuestions: totalQuestions,
    );
  }
}
```

### Remote Data Source

```dart
// lib/features/interview/data/datasources/interview_remote_datasource.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/websocket_client.dart';
import '../models/interview_request_model.dart';
import '../models/interview_response_model.dart';
import '../models/session_stats_model.dart';

abstract class InterviewRemoteDataSource {
  Future<InterviewResponseModel> startMcqInterview(InterviewRequestModel request);
  Future<InterviewResponseModel> submitMcqAnswer(InterviewRequestModel request);
  Stream<InterviewResponseModel> startVoiceInterview(InterviewRequestModel request);
  Future<void> submitVoiceAnswer(InterviewRequestModel request);
  Future<void> endVoiceInterview(String sessionId);
  Future<SessionStatsModel> getSessionStats(String sessionId);
  Future<void> deleteSession(String sessionId);
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final Dio dio;
  final WebSocketClient webSocketClient;

  InterviewRemoteDataSourceImpl({
    required this.dio,
    required this.webSocketClient,
  });

  @override
  Future<InterviewResponseModel> startMcqInterview(InterviewRequestModel request) async {
    try {
      final response = await dio.post(
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
  Future<InterviewResponseModel> submitMcqAnswer(InterviewRequestModel request) async {
    try {
      final response = await dio.post(
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
  Stream<InterviewResponseModel> startVoiceInterview(InterviewRequestModel request) {
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
    webSocketClient.send({
      'type': 'answer',
      'data': request.toJson(),
    });
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
      final response = await dio.get('${ApiConstants.sessionStats}/$sessionId');

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
      final response = await dio.delete('${ApiConstants.deleteSession}/$sessionId');

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
```

### Local Data Source (Appwrite Integration)

```dart
// lib/features/interview/data/datasources/interview_local_datasource.dart
import 'package:appwrite/appwrite.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/interview_session.dart';

abstract class InterviewLocalDataSource {
  Future<void> saveSession(InterviewSession session);
  Future<List<InterviewSession>> getUserSessions(String userId);
  Future<void> updateSession(InterviewSession session);
  Future<void> deleteSession(String sessionId);
}

class InterviewLocalDataSourceImpl implements InterviewLocalDataSource {
  final Databases databases;
  static const String databaseId = 'your_database_id';
  static const String collectionId = 'interview_sessions';

  InterviewLocalDataSourceImpl({required this.databases});

  @override
  Future<void> saveSession(InterviewSession session) async {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: session.sessionId,
        data: _sessionToMap(session),
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to save session');
    }
  }

  @override
  Future<List<InterviewSession>> getUserSessions(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('created_at'),
        ],
      );

      return response.documents
          .map((doc) => _mapToSession(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to fetch sessions');
    }
  }

  @override
  Future<void> updateSession(InterviewSession session) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: session.sessionId,
        data: _sessionToMap(session),
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to update session');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: sessionId,
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to delete session');
    }
  }

  Map<String, dynamic> _sessionToMap(InterviewSession session) {
    return {
      'user_id': session.userId,
      'job_role': session.jobRole,
      'interview_type': session.interviewType.name,
      'difficulty_level': session.difficultyLevel.name,
      'category': session.category.name,
      'num_questions': session.numQuestions,
      'created_at': session.createdAt.toIso8601String(),
      'is_complete': session.isComplete,
    };
  }

  InterviewSession _mapToSession(Map<String, dynamic> data) {
    return InterviewSession(
      sessionId: data['\$id'],
      userId: data['user_id'],
      jobRole: data['job_role'],
      interviewType: InterviewType.values.firstWhere(
        (e) => e.name == data['interview_type'],
      ),
      difficultyLevel: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty_level'],
      ),
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == data['category'],
      ),
      numQuestions: data['num_questions'],
      createdAt: DateTime.parse(data['created_at']),
      isComplete: data['is_complete'] ?? false,
    );
  }
}
```

## 4. Presentation Layer (BLoC)

### MCQ Interview BLoC

```dart
// lib/features/interview/presentation/bloc/mcq_interview/mcq_interview_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/interview_session.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/usecases/start_mcq_interview.dart';
import '../../../domain/usecases/submit_mcq_answer.dart';

part 'mcq_interview_event.dart';
part 'mcq_interview_state.dart';

class McqInterviewBloc extends Bloc<McqInterviewEvent, McqInterviewState> {
  final StartMcqInterview startMcqInterview;
  final SubmitMcqAnswer submitMcqAnswer;

  String? _currentSessionId;
  List<Question> _questions = [];
  List<String> _userAnswers = [];

  McqInterviewBloc({
    required this.startMcqInterview,
    required this.submitMcqAnswer,
  }) : super(McqInterviewInitial()) {
    on<StartMcqInterviewEvent>(_onStartMcqInterview);
    on<SubmitMcqAnswerEvent>(_onSubmitMcqAnswer);
    on<ResetMcqInterviewEvent>(_onResetMcqInterview);
  }

  Future<void> _onStartMcqInterview(
    StartMcqInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    emit(McqInterviewLoading());

    final result = await startMcqInterview(StartMcqInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      category: event.category,
      numQuestions: event.numQuestions,
    ));

    result.fold(
      (failure) => emit(McqInterviewError(failure.message)),
      (question) {
        _currentSessionId = event.sessionId;
        _questions = [question];
        _userAnswers = [];
        emit(McqInterviewQuestionLoaded(
          question: question,
          sessionId: _currentSessionId!,
          questionNumber: 1,
          totalQuestions: event.numQuestions,
        ));
      },
    );
  }

  Future<void> _onSubmitMcqAnswer(
    SubmitMcqAnswerEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    if (_currentSessionId == null) return;

    emit(McqInterviewLoading());

    _userAnswers.add(event.answer);

    final result = await submitMcqAnswer(SubmitMcqAnswerParams(
      sessionId: _currentSessionId!,
      answer: event.answer,
      userId: event.userId,
      jobRole: event.jobRole,
    ));

    result.fold(
      (failure) => emit(McqInterviewError(failure.message)),
      (response) {
        _questions.add(response);

        if (response.currentQuestionNumber == response.totalQuestions) {
          // Interview complete
          emit(McqInterviewCompleted(
            questions: _questions,
            userAnswers: _userAnswers,
            finalScore: response.score ?? 0,
            sessionId: _currentSessionId!,
          ));
        } else {
          // Next question
          emit(McqInterviewQuestionLoaded(
            question: response,
            sessionId: _currentSessionId!,
            questionNumber: response.currentQuestionNumber ?? 0,
            totalQuestions: response.totalQuestions ?? 0,
          ));
        }
      },
    );
  }

  void _onResetMcqInterview(
    ResetMcqInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) {
    _currentSessionId = null;
    _questions.clear();
    _userAnswers.clear();
    emit(McqInterviewInitial());
  }
}
```

### Voice Interview BLoC

```dart
// lib/features/interview/presentation/bloc/voice_interview/voice_interview_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/utils/timer_service.dart';
import '../../../domain/entities/interview_session.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/usecases/start_voice_interview.dart';
import '../../../domain/usecases/submit_voice_answer.dart';

part 'voice_interview_event.dart';
part 'voice_interview_state.dart';

class VoiceInterviewBloc extends Bloc<VoiceInterviewEvent, VoiceInterviewState> {
  final StartVoiceInterview startVoiceInterview;
  final SubmitVoiceAnswer submitVoiceAnswer;
  final TimerService timerService;

  StreamSubscription? _interviewSubscription;
  StreamSubscription? _timerSubscription;
  String? _currentSessionId;
  List<Question> _conversationHistory = [];

  VoiceInterviewBloc({
    required this.startVoiceInterview,
    required this.submitVoiceAnswer,
    required this.timerService,
  }) : super(VoiceInterviewInitial()) {
    on<StartVoiceInterviewEvent>(_onStartVoiceInterview);
    on<SubmitVoiceAnswerEvent>(_onSubmitVoiceAnswer);
    on<EndVoiceInterviewEvent>(_onEndVoiceInterview);
    on<TimerUpdatedEvent>(_onTimerUpdated);
    on<ResetVoiceInterviewEvent>(_onResetVoiceInterview);
  }

  Future<void> _onStartVoiceInterview(
    StartVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    emit(VoiceInterviewLoading());

    // Start timer
    timerService.startTimer(event.durationMinutes);
    _timerSubscription = timerService.timerStream.listen((seconds) {
      if (seconds <= 0) {
        add(EndVoiceInterviewEvent(reason: 'time_up'));
      } else {
        add(TimerUpdatedEvent(seconds));
      }
    });

    final result = await startVoiceInterview(StartVoiceInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      category: event.category,
    ));

    result.fold(
      (failure) {
        timerService.stopTimer();
        emit(VoiceInterviewError(failure.message));
      },
      (stream) {
        _interviewSubscription = stream.listen(
          (result) {
            result.fold(
              (failure) => emit(VoiceInterviewError(failure.message)),
              (question) {
                _conversationHistory.add(question);
                emit(VoiceInterviewQuestionReceived(
                  question: question,
                  conversationHistory: List.from(_conversationHistory),
                  remainingTime: timerService.remainingSeconds,
                ));
              },
            );
          },
          onError: (error) {
            timerService.stopTimer();
            emit(VoiceInterviewError(error.toString()));
          },
        );
      },
    );
  }

  Future<void> _onSubmitVoiceAnswer(
    SubmitVoiceAnswerEvent event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (_currentSessionId == null) return;

    final result = await submitVoiceAnswer(SubmitVoiceAnswerParams(
      sessionId: _currentSessionId!,
      answer: event.answer,
      userId: event.userId,
      jobRole: event.jobRole,
    ));

    result.fold(
      (failure) => emit(VoiceInterviewError(failure.message)),
      (_) {
        // Answer submitted successfully
        // Next question will come through the stream
      },
    );
  }

  void _onEndVoiceInterview(
    EndVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    timerService.stopTimer();
    _interviewSubscription?.cancel();
    _timerSubscription?.cancel();

    emit(VoiceInterviewCompleted(
      conversationHistory: _conversationHistory,
      reason: event.reason,
    ));
  }

  void _onTimerUpdated(
    TimerUpdatedEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceInterviewQuestionReceived) {
      emit(currentState.copyWith(remainingTime: event.seconds));
    }
  }

  void _onResetVoiceInterview(
    ResetVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    timerService.stopTimer();
    _interviewSubscription?.cancel();
    _timerSubscription?.cancel();
    _currentSessionId = null;
    _conversationHistory.clear();
    emit(VoiceInterviewInitial());
  }

  @override
  Future<void> close() {
    timerService.dispose();
    _interviewSubscription?.cancel();
    _timerSubscription?.cancel();
    return super.close();
  }
}
```

## 5. UI Components

### Interview Setup Page

```dart
// lib/features/interview/presentation/pages/interview_setup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/interview_session.dart';
import '../bloc/mcq_interview/mcq_interview_bloc.dart';
import '../bloc/voice_interview/voice_interview_bloc.dart';

class InterviewSetupPage extends StatefulWidget {
  final String userId;

  const InterviewSetupPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<InterviewSetupPage> createState() => _InterviewSetupPageState();
}

class _InterviewSetupPageState extends State<InterviewSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobRoleController = TextEditingController();

  InterviewType _selectedType = InterviewType.mcq;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  QuestionCategory _selectedCategory = QuestionCategory.technical;
  int _selectedQuestions = 10;
  int _selectedDuration = 30; // minutes for voice interview

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Interview'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Job Role Input
              TextFormField(
                controller: _jobRoleController,
                decoration: const InputDecoration(
                  labelText: 'Job Role',
                  hintText: 'e.g., Software Engineer, Data Scientist',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interview Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interview Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RadioListTile<InterviewType>(
                        title: const Text('MCQ Interview'),
                        subtitle: const Text('Multiple choice questions'),
                        value: InterviewType.mcq,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                      ),
                      RadioListTile<InterviewType>(
                        title: const Text('Voice Interview'),
                        subtitle: const Text('Conversational interview'),
                        value: InterviewType.voice,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Difficulty Level
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Difficulty Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButtonFormField<DifficultyLevel>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: DifficultyLevel.values.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDifficulty = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question Category
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Question Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButtonFormField<QuestionCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: QuestionCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_formatCategoryName(category.name)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // MCQ Specific Options
              if (_selectedType == InterviewType.mcq) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Number of Questions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: _selectedQuestions,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [5, 10, 15, 20].map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('$count Questions'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedQuestions = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Voice Interview Specific Options
              if (_selectedType == InterviewType.voice) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interview Duration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: _selectedDuration,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [15, 30, 45, 60].map((duration) {
                            return DropdownMenuItem(
                              value: duration,
                              child: Text('$duration Minutes'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDuration = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Start Interview Button
              ElevatedButton(
                onPressed: _startInterview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text('Start ${_selectedType.name.toUpperCase()} Interview'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String name) {
    return name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _startInterview() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == InterviewType.mcq) {
      context.read<McqInterviewBloc>().add(StartMcqInterviewEvent(
        userId: widget.userId,
        jobRole: _jobRoleController.text.trim(),
        difficultyLevel: _selectedDifficulty,
        category: _selectedCategory,
        numQuestions: _selectedQuestions,
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      ));

      Navigator.pushNamed(context, '/mcq-interview');
    } else {
      context.read<VoiceInterviewBloc>().add(StartVoiceInterviewEvent(
        userId: widget.userId,
        jobRole: _jobRoleController.text.trim(),
        difficultyLevel: _selectedDifficulty,
        category: _selectedCategory,
        durationMinutes: _selectedDuration,
      ));

      Navigator.pushNamed(context, '/voice-interview');
    }
  }

  @override
  void dispose() {
    _jobRoleController.dispose();
    super.dispose();
  }
}
```

## 6. Dependency Injection

```dart
// lib/core/di/injection_container.dart
import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/interview/data/datasources/interview_local_datasource.dart';
import '../../features/interview/data/datasources/interview_remote_datasource.dart';
import '../../features/interview/data/repositories/interview_repository_impl.dart';
import '../../features/interview/domain/repositories/interview_repository.dart';
import '../../features/interview/domain/usecases/start_mcq_interview.dart';
import '../../features/interview/domain/usecases/submit_mcq_answer.dart';
import '../../features/interview/domain/usecases/start_voice_interview.dart';
import '../../features/interview/domain/usecases/submit_voice_answer.dart';
import '../../features/interview/presentation/bloc/mcq_interview/mcq_interview_bloc.dart';
import '../../features/interview/presentation/bloc/voice_interview/voice_interview_bloc.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/websocket_client.dart';
import '../utils/timer_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() => ApiClient().dio);
  getIt.registerLazySingleton(() => WebSocketClient());
  getIt.registerLazySingleton(() => Client()
    ..setEndpoint('https://your-appwrite-endpoint.com/v1')
    ..setProject('your-project-id'));
  getIt.registerLazySingleton(() => Databases(getIt<Client>()));

  // Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );
  getIt.registerFactory(() => TimerService());

  // Data sources
  getIt.registerLazySingleton<InterviewRemoteDataSource>(
    () => InterviewRemoteDataSourceImpl(
      dio: getIt(),
      webSocketClient: getIt(),
    ),
  );
  getIt.registerLazySingleton<InterviewLocalDataSource>(
    () => InterviewLocalDataSourceImpl(databases: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => StartMcqInterview(getIt()));
  getIt.registerLazySingleton(() => SubmitMcqAnswer(getIt()));
  getIt.registerLazySingleton(() => StartVoiceInterview(getIt()));
  getIt.registerLazySingleton(() => SubmitVoiceAnswer(getIt()));

  // BLoC
  getIt.registerFactory(
    () => McqInterviewBloc(
      startMcqInterview: getIt(),
      submitMcqAnswer: getIt(),
    ),
  );
  getIt.registerFactory(
    () => VoiceInterviewBloc(
      startVoiceInterview: getIt(),
      submitVoiceAnswer: getIt(),
      timerService: getIt(),
    ),
  );
}
```

## 7. Main App Setup

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'features/interview/presentation/bloc/mcq_interview/mcq_interview_bloc.dart';
import 'features/interview/presentation/bloc/voice_interview/voice_interview_bloc.dart';
import 'features/interview/presentation/pages/interview_setup_page.dart';
import 'features/interview/presentation/pages/mcq_interview_page.dart';
import 'features/interview/presentation/pages/voice_interview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<McqInterviewBloc>(
          create: (context) => di.getIt<McqInterviewBloc>(),
        ),
        BlocProvider<VoiceInterviewBloc>(
          create: (context) => di.getIt<VoiceInterviewBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'AI Interview App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/setup',
        routes: {
          '/setup': (context) => const InterviewSetupPage(userId: 'current_user_id'),
          '/mcq-interview': (context) => const McqInterviewPage(),
          '/voice-interview': (context) => const VoiceInterviewPage(),
        },
      ),
    );
  }
}
```

## 8. Required Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Network
  dio: ^5.3.2
  web_socket_channel: ^2.4.0
  connectivity_plus: ^4.0.2
  pretty_dio_logger: ^1.3.1

  # Functional Programming
  dartz: ^0.10.1

  # Dependency Injection
  get_it: ^7.6.4

  # Appwrite
  appwrite: ^11.0.0

  # UI
  flutter_screenutil: ^5.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 9. API Usage Examples

### Starting MCQ Interview

```dart
// In your BLoC or use case
final result = await interviewRepository.startMcqInterview(
  userId: 'user123',
  jobRole: 'Software Engineer',
  difficultyLevel: DifficultyLevel.medium,
  category: QuestionCategory.technical,
  numQuestions: 10,
);
```

### Starting Voice Interview

```dart
// In your BLoC
final stream = await interviewRepository.startVoiceInterview(
  userId: 'user123',
  jobRole: 'Data Scientist',
  difficultyLevel: DifficultyLevel.hard,
  category: QuestionCategory.industry_specific,
);

// Listen to stream for real-time questions
stream.listen((result) {
  result.fold(
    (failure) => handleError(failure),
    (question) => displayQuestion(question),
  );
});
```

## 10. Best Practices

### Error Handling

- Use `Either<Failure, T>` for all repository methods
- Implement specific exception types for different error scenarios
- Show user-friendly error messages in the UI

### State Management

- Keep business logic in BLoCs, not in UI widgets
- Use immutable state objects with `copyWith` methods
- Handle loading, success, and error states consistently

### Appwrite Integration

- Store interview sessions for user history
- Use Appwrite queries for filtering and sorting
- Implement offline-first approach with local caching

### Performance

- Use `StreamBuilder` for real-time updates
- Implement proper disposal of streams and timers
- Cache responses to reduce API calls

This comprehensive guide provides everything you need to integrate the AI Interview Agent with your Flutter app using Clean Architecture, SOLID principles, BLoC pattern, and Appwrite!

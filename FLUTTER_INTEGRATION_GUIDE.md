# MCQ Interview Agent - Flutter Integration Guide (Clean Architecture, SOLID, BLoC, Dio)

## Overview

This guide explains how to integrate your MCQ-based interview agent with a Flutter app using Clean Architecture, SOLID principles, BLoC for state management, and Dio for networking. The structure ensures testability, scalability, and maintainability.

## Table of Contents

1. [API Overview](#api-overview)
2. [Flutter Setup](#flutter-setup)
3. [Project Structure (Clean Architecture)](#project-structure-clean-architecture)
4. [Networking with Dio](#networking-with-dio)
5. [Domain Layer: Entities & Use Cases](#domain-layer-entities--use-cases)
6. [Data Layer: Models & Repositories](#data-layer-models--repositories)
7. [Presentation Layer: BLoC & UI](#presentation-layer-bloc--ui)
8. [Error Handling](#error-handling)
9. [Testing](#testing)
10. [Deployment](#deployment)

## API Overview

**Base URL:**

```
http://localhost:8000  # Development
https://your-domain.com  # Production
```

**Endpoints:**

| Method | Endpoint                             | Description                           |
| ------ | ------------------------------------ | ------------------------------------- |
| POST   | `/api/v1/start_interview`            | Start new MCQ interview session       |
| POST   | `/api/v1/submit_answer`              | Submit all answers and get evaluation |
| GET    | `/api/v1/session_stats/{session_id}` | Get session statistics                |
| DELETE | `/api/v1/session/{session_id}`       | Delete session                        |
| GET    | `/api/v1/active_sessions`            | Get active session count              |
| GET    | `/health`                            | Health check                          |

## Flutter Setup

### Dependencies (Updated for Clean Architecture)

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Networking
  dio: ^5.4.0

  # State Management
  flutter_bloc: ^8.1.3

  # Functional Programming
  dartz: ^0.10.1

  # Value Equality
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^7.6.0

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## Project Structure (Clean Architecture)

```
lib/
├── core/
│   ├── error/
│   │   └── failure.dart
│   ├── network/
│   │   └── dio_client.dart
│   └── utils/
│       └── constants.dart
├── features/
│   └── interview/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── interview_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── interview_model.dart
│       │   │   ├── question_model.dart
│       │   │   └── evaluation_result_model.dart
│       │   └── repositories/
│       │       └── interview_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── interview.dart
│       │   │   ├── question.dart
│       │   │   └── evaluation_result.dart
│       │   ├── repositories/
│       │   │   └── interview_repository.dart
│       │   └── usecases/
│       │       ├── start_interview.dart
│       │       ├── submit_answers.dart
│       │       └── get_session_stats.dart
│       ├── presentation/
│       │   ├── bloc/
│       │   │   └── interview_bloc.dart
│       │   ├── pages/
│       │   │   ├── interview_config_page.dart
│       │   │   ├── interview_page.dart
│       │   │   └── results_page.dart
│       │   └── widgets/
│       │       ├── question_card.dart
│       │       └── progress_indicator.dart
└── injection_container.dart
```

## Domain Layer: Entities & Use Cases

### Core Error Handling

```dart
// lib/core/error/failure.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  @override
  List<Object> get props => [];
}

class CacheFailure extends Failure {
  @override
  List<Object> get props => [];
}
```

### Domain Entities

```dart
// lib/features/interview/domain/entities/interview.dart
import 'package:equatable/equatable.dart';
import 'question.dart';

class Interview extends Equatable {
  final String sessionId;
  final String jobRole;
  final String difficulty;
  final String category;
  final int totalQuestions;
  final List<Question> questions;
  final String message;
  final DateTime sessionCreatedAt;

  const Interview({
    required this.sessionId,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
    required this.questions,
    required this.message,
    required this.sessionCreatedAt,
  });

  @override
  List<Object> get props => [
        sessionId,
        jobRole,
        difficulty,
        category,
        totalQuestions,
        questions,
        message,
        sessionCreatedAt,
      ];
}
```

```dart
// lib/features/interview/domain/entities/question.dart
import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;
  final String category;
  final String topic;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.topic,
  });

  @override
  List<Object> get props => [
        id,
        question,
        options,
        correctAnswer,
        explanation,
        difficulty,
        category,
        topic,
      ];
}
```

```dart
// lib/features/interview/domain/entities/evaluation_result.dart
import 'package:equatable/equatable.dart';

class EvaluationResult extends Equatable {
  final String sessionId;
  final int totalQuestions;
  final List<QuestionResult> results;
  final double finalScore;
  final double percentage;
  final bool passed;
  final bool sessionComplete;
  final DateTime completedAt;

  const EvaluationResult({
    required this.sessionId,
    required this.totalQuestions,
    required this.results,
    required this.finalScore,
    required this.percentage,
    required this.passed,
    required this.sessionComplete,
    required this.completedAt,
  });

  @override
  List<Object> get props => [
        sessionId,
        totalQuestions,
        results,
        finalScore,
        percentage,
        passed,
        sessionComplete,
        completedAt,
      ];
}

class QuestionResult extends Equatable {
  final int questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int score;
  final String explanation;

  const QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.score,
    required this.explanation,
  });

  @override
  List<Object> get props => [
        questionId,
        question,
        userAnswer,
        correctAnswer,
        isCorrect,
        score,
        explanation,
      ];
}
```

### Domain Repository

```dart
// lib/features/interview/domain/repositories/interview_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/interview.dart';
import '../entities/evaluation_result.dart';

abstract class InterviewRepository {
  Future<Either<Failure, Interview>> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  });

  Future<Either<Failure, EvaluationResult>> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  });

  Future<Either<Failure, Map<String, dynamic>>> getSessionStats(String sessionId);
  Future<Either<Failure, void>> deleteSession(String sessionId);
  Future<Either<Failure, Map<String, dynamic>>> getActiveSessions();
  Future<Either<Failure, bool>> checkHealth();
}
```

### Use Cases

```dart
// lib/features/interview/domain/usecases/start_interview.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/interview.dart';
import '../repositories/interview_repository.dart';

class StartInterview implements UseCase<Interview, StartInterviewParams> {
  final InterviewRepository repository;

  StartInterview(this.repository);

  @override
  Future<Either<Failure, Interview>> call(StartInterviewParams params) async {
    return await repository.startInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      numQuestions: params.numQuestions,
      category: params.category,
    );
  }
}

class StartInterviewParams extends Equatable {
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final int numQuestions;
  final String category;

  const StartInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });

  @override
  List<Object> get props => [userId, jobRole, difficultyLevel, numQuestions, category];
}
```

```dart
// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

```dart
// lib/features/interview/domain/usecases/submit_answers.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/evaluation_result.dart';
import '../repositories/interview_repository.dart';

class SubmitAnswers implements UseCase<EvaluationResult, SubmitAnswersParams> {
  final InterviewRepository repository;

  SubmitAnswers(this.repository);

  @override
  Future<Either<Failure, EvaluationResult>> call(SubmitAnswersParams params) async {
    return await repository.submitAnswers(
      sessionId: params.sessionId,
      userId: params.userId,
      answers: params.answers,
    );
  }
}

class SubmitAnswersParams extends Equatable {
  final String sessionId;
  final String userId;
  final List<String> answers;

  const SubmitAnswersParams({
    required this.sessionId,
    required this.userId,
    required this.answers,
  });

  @override
  List<Object> get props => [sessionId, userId, answers];
}
```

## Data Layer: Models & Repositories

### Networking with Dio

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  DioClient(this.dio);

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await dio.get(path);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
```

### Data Models

```dart
// lib/features/interview/data/models/interview_model.dart
import '../../domain/entities/interview.dart';
import 'question_model.dart';

class InterviewModel extends Interview {
  const InterviewModel({
    required super.sessionId,
    required super.jobRole,
    required super.difficulty,
    required super.category,
    required super.totalQuestions,
    required super.questions,
    required super.message,
    required super.sessionCreatedAt,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      sessionId: json['session_id'] as String,
      jobRole: json['job_role'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      totalQuestions: json['total_questions'] as int,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList(),
      message: json['message'] as String,
      sessionCreatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['session_created_at'] as num).toInt() * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'job_role': jobRole,
      'difficulty': difficulty,
      'category': category,
      'total_questions': totalQuestions,
      'questions': questions.map((q) => (q as QuestionModel).toJson()).toList(),
      'message': message,
      'session_created_at': sessionCreatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
```

```dart
// lib/features/interview/data/models/question_model.dart
import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctAnswer,
    required super.explanation,
    required super.difficulty,
    required super.category,
    required super.topic,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      topic: json['topic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'topic': topic,
    };
  }
}
```

```dart
// lib/features/interview/data/models/evaluation_result_model.dart
import '../../domain/entities/evaluation_result.dart';

class EvaluationResultModel extends EvaluationResult {
  const EvaluationResultModel({
    required super.sessionId,
    required super.totalQuestions,
    required super.results,
    required super.finalScore,
    required super.percentage,
    required super.passed,
    required super.sessionComplete,
    required super.completedAt,
  });

  factory EvaluationResultModel.fromJson(Map<String, dynamic> json) {
    return EvaluationResultModel(
      sessionId: json['session_id'] as String,
      totalQuestions: json['total_questions'] as int,
      results: (json['results'] as List)
          .map((r) => QuestionResultModel.fromJson(r))
          .toList(),
      finalScore: (json['final_score'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] as bool,
      sessionComplete: json['session_complete'] as bool,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['completed_at'] as num).toInt() * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'total_questions': totalQuestions,
      'results': results.map((r) => (r as QuestionResultModel).toJson()).toList(),
      'final_score': finalScore,
      'percentage': percentage,
      'passed': passed,
      'session_complete': sessionComplete,
      'completed_at': completedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

class QuestionResultModel extends QuestionResult {
  const QuestionResultModel({
    required super.questionId,
    required super.question,
    required super.userAnswer,
    required super.correctAnswer,
    required super.isCorrect,
    required super.score,
    required super.explanation,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultModel(
      questionId: json['question_id'] as int,
      question: json['question'] as String,
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      score: json['score'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'score': score,
      'explanation': explanation,
    };
  }
}
```

```dart
// lib/features/interview/data/models/interview_request_model.dart
class InterviewRequestModel {
  final String userId;
  final String jobRole;
  final String interviewType;
  final String difficultyLevel;
  final int numQuestions;
  final String category;
  final List<String>? answers;
  final String? questionId;

  const InterviewRequestModel({
    required this.userId,
    required this.jobRole,
    this.interviewType = 'mcq',
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
    this.answers,
    this.questionId,
  });

  factory InterviewRequestModel.fromJson(Map<String, dynamic> json) {
    return InterviewRequestModel(
      userId: json['user_id'] as String,
      jobRole: json['job_role'] as String,
      interviewType: json['interview_type'] as String? ?? 'mcq',
      difficultyLevel: json['difficulty_level'] as String,
      numQuestions: json['num_questions'] as int,
      category: json['category'] as String,
      answers: json['answers'] != null ? List<String>.from(json['answers']) : null,
      questionId: json['question_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel,
      'num_questions': numQuestions,
      'category': category,
      if (answers != null) 'answers': answers,
      if (questionId != null) 'question_id': questionId,
    };
  }
}
```

### Remote Data Source

```dart
// lib/features/interview/data/datasources/interview_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/interview_model.dart';
import '../models/evaluation_result_model.dart';
import '../models/interview_request_model.dart';

abstract class InterviewRemoteDataSource {
  Future<InterviewModel> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
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
  final DioClient dioClient;

  InterviewRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<InterviewModel> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    final request = InterviewRequestModel(
      userId: userId,
      jobRole: jobRole,
      difficultyLevel: difficultyLevel,
      numQuestions: numQuestions,
      category: category,
    );

    final response = await dioClient.post(
      '/api/v1/start_interview',
      data: request.toJson(),
    );

    return InterviewModel.fromJson(response.data);
  }

  @override
  Future<EvaluationResultModel> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  }) async {
    final request = InterviewRequestModel(
      userId: userId,
      jobRole: '', // Not needed for submission
      difficultyLevel: 'medium', // Not needed for submission
      numQuestions: answers.length,
      category: 'technical', // Not needed for submission
      questionId: sessionId,
      answers: answers,
    );

    final response = await dioClient.post(
      '/api/v1/submit_answer',
      data: request.toJson(),
    );

    return EvaluationResultModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    final response = await dioClient.get('/api/v1/session_stats/$sessionId');
    return response.data;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await dioClient.delete('/api/v1/session/$sessionId');
  }

  @override
  Future<Map<String, dynamic>> getActiveSessions() async {
    final response = await dioClient.get('/api/v1/active_sessions');
    return response.data;
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await dioClient.get('/health');
      return response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
}
```

### Repository Implementation

````dart
// lib/features/interview/data/repositories/interview_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/interview.dart';
import '../../domain/entities/evaluation_result.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_remote_datasource.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewRemoteDataSource remoteDataSource;

  InterviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Interview>> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    try {
      final interview = await remoteDataSource.startInterview(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        numQuestions: numQuestions,
        category: category,
      );
      return Right(interview);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EvaluationResult>> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  }) async {
    try {
      final result = await remoteDataSource.submitAnswers(
        sessionId: sessionId,
        userId: userId,
        answers: answers,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSessionStats(String sessionId) async {
    try {
      final stats = await remoteDataSource.getSessionStats(sessionId);
      return Right(stats);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getActiveSessions() async {
    try {
      final sessions = await remoteDataSource.getActiveSessions();
      return Right(sessions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkHealth() async {
    try {
      final isHealthy = await remoteDataSource.checkHealth();
      return Right(isHealthy);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final message = e.response?.data?['error'] ??
                       e.response?.data?['detail'] ??
                       'Server error';
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }
}

## Presentation Layer: BLoC & UI

### BLoC Events

```dart
// lib/features/interview/presentation/bloc/interview_event.dart
import 'package:equatable/equatable.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object> get props => [];
}

class StartInterviewEvent extends InterviewEvent {
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final int numQuestions;
  final String category;

  const StartInterviewEvent({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });

  @override
  List<Object> get props => [userId, jobRole, difficultyLevel, numQuestions, category];
}

class SelectAnswerEvent extends InterviewEvent {
  final int questionIndex;
  final String answer;

  const SelectAnswerEvent({
    required this.questionIndex,
    required this.answer,
  });

  @override
  List<Object> get props => [questionIndex, answer];
}

class NextQuestionEvent extends InterviewEvent {}

class PreviousQuestionEvent extends InterviewEvent {}

class GoToQuestionEvent extends InterviewEvent {
  final int questionIndex;

  const GoToQuestionEvent(this.questionIndex);

  @override
  List<Object> get props => [questionIndex];
}

class SubmitInterviewEvent extends InterviewEvent {
  final String sessionId;
  final String userId;
  final List<String> answers;

  const SubmitInterviewEvent({
    required this.sessionId,
    required this.userId,
    required this.answers,
  });

  @override
  List<Object> get props => [sessionId, userId, answers];
}

class ResetInterviewEvent extends InterviewEvent {}
````

### BLoC States

```dart
// lib/features/interview/presentation/bloc/interview_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/interview.dart';
import '../../domain/entities/evaluation_result.dart';

abstract class InterviewState extends Equatable {
  const InterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewStarted extends InterviewState {
  final Interview interview;
  final List<String> userAnswers;
  final int currentQuestionIndex;

  const InterviewStarted({
    required this.interview,
    required this.userAnswers,
    required this.currentQuestionIndex,
  });

  @override
  List<Object> get props => [interview, userAnswers, currentQuestionIndex];

  InterviewStarted copyWith({
    Interview? interview,
    List<String>? userAnswers,
    int? currentQuestionIndex,
  }) {
    return InterviewStarted(
      interview: interview ?? this.interview,
      userAnswers: userAnswers ?? this.userAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

class InterviewCompleted extends InterviewState {
  final EvaluationResult evaluationResult;

  const InterviewCompleted({required this.evaluationResult});

  @override
  List<Object> get props => [evaluationResult];
}

class InterviewError extends InterviewState {
  final String message;

  const InterviewError({required this.message});

  @override
  List<Object> get props => [message];
}
```

### BLoC Implementation

```dart
// lib/features/interview/presentation/bloc/interview_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/usecases/start_interview.dart';
import '../../domain/usecases/submit_answers.dart';
import 'interview_event.dart';
import 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartInterview startInterviewUseCase;
  final SubmitAnswers submitAnswersUseCase;

  InterviewBloc({
    required this.startInterviewUseCase,
    required this.submitAnswersUseCase,
  }) : super(InterviewInitial()) {
    on<StartInterviewEvent>(_onStartInterview);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<GoToQuestionEvent>(_onGoToQuestion);
    on<SubmitInterviewEvent>(_onSubmitInterview);
    on<ResetInterviewEvent>(_onResetInterview);
  }

  Future<void> _onStartInterview(
    StartInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    emit(InterviewLoading());

    final result = await startInterviewUseCase(StartInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      numQuestions: event.numQuestions,
      category: event.category,
    ));

    result.fold(
      (failure) => emit(InterviewError(message: _mapFailureToMessage(failure))),
      (interview) => emit(InterviewStarted(
        interview: interview,
        userAnswers: List.filled(interview.questions.length, ''),
        currentQuestionIndex: 0,
      )),
    );
  }

  void _onSelectAnswer(
    SelectAnswerEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      final updatedAnswers = List<String>.from(currentState.userAnswers);
      updatedAnswers[event.questionIndex] = event.answer;

      emit(currentState.copyWith(userAnswers: updatedAnswers));
    }
  }

  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (currentState.currentQuestionIndex < currentState.interview.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  void _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (currentState.currentQuestionIndex > 0) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ));
      }
    }
  }

  void _onGoToQuestion(
    GoToQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (event.questionIndex >= 0 &&
          event.questionIndex < currentState.interview.questions.length) {
        emit(currentState.copyWith(currentQuestionIndex: event.questionIndex));
      }
    }
  }

  Future<void> _onSubmitInterview(
    SubmitInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    emit(InterviewLoading());

    final result = await submitAnswersUseCase(SubmitAnswersParams(
      sessionId: event.sessionId,
      userId: event.userId,
      answers: event.answers,
    ));

    result.fold(
      (failure) => emit(InterviewError(message: _mapFailureToMessage(failure))),
      (evaluationResult) => emit(InterviewCompleted(evaluationResult: evaluationResult)),
    );
  }

  void _onResetInterview(
    ResetInterviewEvent event,
    Emitter<InterviewState> emit,
  ) {
    emit(InterviewInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is CacheFailure) {
      return 'Cache error occurred.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
```

### Dependency Injection Container

```dart
// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'features/interview/data/datasources/interview_remote_datasource.dart';
import 'features/interview/data/repositories/interview_repository_impl.dart';
import 'features/interview/domain/repositories/interview_repository.dart';
import 'features/interview/domain/usecases/start_interview.dart';
import 'features/interview/domain/usecases/submit_answers.dart';
import 'features/interview/presentation/bloc/interview_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  )));

  // Core
  sl.registerLazySingleton(() => DioClient(sl()));

  // Data sources
  sl.registerLazySingleton<InterviewRemoteDataSource>(
    () => InterviewRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => StartInterview(sl()));
  sl.registerLazySingleton(() => SubmitAnswers(sl()));

  // BLoC
  sl.registerFactory(() => InterviewBloc(
    startInterviewUseCase: sl(),
    submitAnswersUseCase: sl(),
  ));
}
```

### Updated Main App

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/interview/presentation/bloc/interview_bloc.dart';
import 'features/interview/presentation/pages/interview_config_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Interview App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => di.sl<InterviewBloc>(),
        child: const InterviewConfigPage(),
      ),
    );
  }
}
```

## UI Components

### 1. Interview Configuration Screen

```dart
// lib/screens/interview_config_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/interview_provider.dart';
import 'interview_screen.dart';

class InterviewConfigScreen extends StatefulWidget {
  const InterviewConfigScreen({Key? key}) : super(key: key);

  @override
  State<InterviewConfigScreen> createState() => _InterviewConfigScreenState();
}

class _InterviewConfigScreenState extends State<InterviewConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobRoleController = TextEditingController();

  String _selectedDifficulty = 'medium';
  int _selectedQuestions = 10;
  String _selectedCategory = 'technical';

  @override
  void dispose() {
    _jobRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Configuration'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Job Role Input
                  TextFormField(
                    controller: _jobRoleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a job role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Selection
                  DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Number of Questions
                  DropdownButtonFormField<int>(
                    value: _selectedQuestions,
                    decoration: const InputDecoration(
                      labelText: 'Number of Questions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.quiz),
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 Questions')),
                      DropdownMenuItem(value: 10, child: Text('10 Questions')),
                      DropdownMenuItem(value: 15, child: Text('15 Questions')),
                      DropdownMenuItem(value: 20, child: Text('20 Questions')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestions = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'technical', child: Text('Technical')),
                      DropdownMenuItem(value: 'behavioral', child: Text('Behavioral')),
                      DropdownMenuItem(value: 'general', child: Text('General')),
                      DropdownMenuItem(value: 'industry_specific', child: Text('Industry Specific')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Start Interview Button
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _startInterview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Start Interview'),
                  ),

                  // Error Display
                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        provider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startInterview() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<InterviewProvider>(context, listen: false);

      await provider.startInterview(
        userId: 'user_123', // Replace with actual user ID
        jobRole: _jobRoleController.text,
        difficultyLevel: _selectedDifficulty,
        numQuestions: _selectedQuestions,
        category: _selectedCategory,
      );

      if (provider.currentInterview != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InterviewScreen(),
          ),
        );
      }
    }
  }
}
```

### 2. Interview Screen

```dart
// lib/screens/interview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/interview_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/progress_indicator.dart';
import 'results_screen.dart';

class InterviewScreen extends StatelessWidget {
  const InterviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Interview'),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, provider, child) {
          if (provider.currentInterview == null) {
            return const Center(
              child: Text('No interview data available'),
            );
          }

          return Column(
            children: [
              // Progress Indicator
              InterviewProgressIndicator(
                current: provider.currentQuestionIndex + 1,
                total: provider.currentInterview!.questions.length,
                progress: provider.progress,
              ),

              // Question Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: QuestionCard(
                    question: provider.currentQuestion!,
                    selectedAnswer: provider.userAnswers[provider.currentQuestionIndex],
                    onAnswerSelected: provider.selectAnswer,
                  ),
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Previous Button
                    if (provider.hasPreviousQuestion)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.goToPreviousQuestion,
                          child: const Text('Previous'),
                        ),
                      ),

                    if (provider.hasPreviousQuestion && provider.hasNextQuestion)
                      const SizedBox(width: 16),

                    // Next/Submit Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getNextAction(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.hasNextQuestion
                              ? null
                              : Theme.of(context).primaryColor,
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(provider.hasNextQuestion ? 'Next' : 'Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  VoidCallback? _getNextAction(BuildContext context, InterviewProvider provider) {
    if (provider.isLoading) return null;

    if (provider.hasNextQuestion) {
      return provider.goToNextQuestion;
    } else {
      return () => _submitInterview(context, provider);
    }
  }

  void _submitInterview(BuildContext context, InterviewProvider provider) async {
    // Check if all questions are answered
    bool hasUnanswered = provider.userAnswers.any((answer) => answer.isEmpty);

    if (hasUnanswered) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Interview'),
          content: const Text(
            'Some questions are not answered. Do you want to submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (shouldSubmit != true) return;
    }

    await provider.submitInterview();

    if (provider.evaluationResult != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResultsScreen(),
        ),
      );
    }
  }
}
```

### 3. Question Card Widget

```dart
// lib/widgets/question_card.dart
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            Text(
              'Q${question.id}: ${question.question}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = selectedAnswer == option;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => onAnswerSelected(option),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                ),
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Results Screen

```dart
// lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/interview_provider.dart';
import 'interview_config_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Results'),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, provider, child) {
          final result = provider.evaluationResult;

          if (result == null) {
            return const Center(
              child: Text('No results available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Summary Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          result.passed ? Icons.check_circle : Icons.cancel,
                          size: 80,
                          color: result.passed ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${result.percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: result.passed ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.passed ? 'Congratulations!' : 'Keep Learning!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              context,
                              'Correct',
                              '${result.results.where((r) => r.isCorrect).length}',
                              Colors.green,
                            ),
                            _buildStatItem(
                              context,
                              'Incorrect',
                              '${result.results.where((r) => !r.isCorrect).length}',
                              Colors.red,
                            ),
                            _buildStatItem(
                              context,
                              'Total',
                              '${result.totalQuestions}',
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Detailed Results
                Text(
                  'Detailed Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...result.results.map((questionResult) =>
                  _buildQuestionResultCard(context, questionResult)),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startNewInterview(context, provider),
                        child: const Text('New Interview'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        ),
                        child: const Text('Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResultCard(BuildContext context, dynamic questionResult) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  questionResult.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: questionResult.isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Question ${questionResult.questionId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              questionResult.question,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildAnswerRow(context, 'Your Answer:', questionResult.userAnswer,
                questionResult.isCorrect ? Colors.green : Colors.red),
            if (!questionResult.isCorrect) ...[
              const SizedBox(height: 4),
              _buildAnswerRow(context, 'Correct Answer:',
                  questionResult.correctAnswer, Colors.green),
            ],
            if (questionResult.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  questionResult.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(BuildContext context, String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _startNewInterview(BuildContext context, InterviewProvider provider) {
    provider.resetInterview();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const InterviewConfigScreen(),
      ),
      (route) => false,
    );
  }
}
```

## Main App Setup

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/interview_provider.dart';
import 'screens/interview_config_screen.dart';
import 'services/api_service.dart';

void main() {
  // Initialize API service
  ApiService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InterviewProvider(),
      child: MaterialApp(
        title: 'MCQ Interview App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const InterviewConfigScreen(),
      ),
    );
  }
}
```

## Error Handling

### 1. Network Error Handling

```dart
// lib/utils/error_handler.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 404:
          return 'Session not found or expired.';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
          return 'Server error. Please try again.';
        case 0:
          return 'No internet connection. Please check your network.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred.';
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(getErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Testing

### 1. Unit Tests

```dart
// test/services/interview_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/services/interview_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  group('InterviewService', () {
    late InterviewService interviewService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      interviewService = InterviewService();
      // Inject mock dependency
    });

    test('should start interview successfully', () async {
      // Arrange
      final mockResponse = {
        'session_id': 'test-session',
        'job_role': 'Software Engineer',
        'questions': [],
      };

      when(mockApiService.post(any, body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await interviewService.startInterview(
        userId: 'test-user',
        jobRole: 'Software Engineer',
        difficultyLevel: 'medium',
        numQuestions: 5,
        category: 'technical',
      );

      // Assert
      expect(result.sessionId, 'test-session');
      expect(result.jobRole, 'Software Engineer');
    });
  });
}
```

## Deployment

### 1. Backend Deployment

```bash
# Using Docker
docker build -t mcq-interview-api .
docker run -p 8000:8000 mcq-interview-api

# Or using Heroku
heroku create mcq-interview-api
git push heroku main
```

### 2. Flutter Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

### 3. Environment Configuration

```dart
// lib/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}
```

## Security Considerations

1. **API Keys**: Store sensitive data in secure storage
2. **Network Security**: Use HTTPS in production
3. **Input Validation**: Validate all user inputs
4. **Session Management**: Implement proper session cleanup
5. **Rate Limiting**: Respect API rate limits

## Performance Optimization

1. **Caching**: Cache questions locally when possible
2. **Lazy Loading**: Load images and content as needed
3. **Memory Management**: Properly dispose of controllers and providers
4. **Network Optimization**: Minimize API calls

## Conclusion

This integration guide provides a complete solution for connecting your MCQ Interview Agent with a Flutter application. The implementation includes:

- Complete API integration with error handling
- Proper state management using Provider
- Responsive UI components
- Comprehensive testing approach
- Production deployment considerations

For additional features like offline support, push notifications, or advanced analytics, refer to the specific Flutter documentation for those capabilities.

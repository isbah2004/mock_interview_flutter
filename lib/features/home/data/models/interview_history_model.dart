import 'package:flutter/material.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';

enum InterviewType { mcq, voice }

enum InterviewDifficulty { easy, medium, hard }

enum InterviewStatus { completed, inProgress, failed }

class InterviewHistoryModel {
  final String id;
  final InterviewType type;
  final String jobRole;
  final String category;
  final InterviewDifficulty difficulty;
  final IconData icon;
  final int? score;
  final bool isComplete;
  final String date;
  final String duration;
  final DateTime? completedAt;
  final int? totalQuestions;
  final double? finalScore;
  final InterviewStatus status;
  final bool passed;

  final EvaluationResultModel? mcqResult;
  final InterviewSession? voiceSession;
  final InterviewConfig? voiceConfig;

  final UnifiedInterviewSession? sessionData;

  const InterviewHistoryModel({
    required this.id,
    required this.type,
    required this.jobRole,
    required this.category,
    required this.difficulty,
    required this.icon,
    this.score,
    required this.isComplete,
    required this.date,
    required this.duration,
    this.completedAt,
    this.totalQuestions,
    this.finalScore,
    required this.status,
    required this.passed,
    this.mcqResult,
    this.voiceSession,
    this.voiceConfig,
    this.sessionData,
  });

  factory InterviewHistoryModel.fromMap(Map<String, dynamic> map) {
    return InterviewHistoryModel(
      id: map['id'] ?? '',
      type: _parseInterviewType(map['type']),
      jobRole: map['jobRole'] ?? '',
      category: map['category'] ?? '',
      difficulty: _parseDifficulty(map['difficulty']),
      icon: _parseIcon(map['icon']),
      score: map['score']?.toInt(),
      isComplete: map['isComplete'] ?? false,
      date: map['date'] ?? '',
      duration: map['duration'] ?? '',
      completedAt:
          map['completedAt'] != null
              ? DateTime.parse(map['completedAt'])
              : null,
      totalQuestions: map['totalQuestions']?.toInt(),
      finalScore: map['finalScore']?.toDouble(),
      status: _parseStatus(map['status']),
      passed: map['passed'] ?? false,
      mcqResult: map['result'] as EvaluationResultModel?,
      voiceSession: map['session'] as InterviewSession?,
      voiceConfig: map['config'] as InterviewConfig?,
      sessionData: map['sessionData'] as UnifiedInterviewSession?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'jobRole': jobRole,
      'category': category,
      'difficulty': difficulty.name,
      'icon': icon.codePoint,
      'score': score,
      'isComplete': isComplete,
      'date': date,
      'duration': duration,
      'completedAt': completedAt?.toIso8601String(),
      'totalQuestions': totalQuestions,
      'finalScore': finalScore,
      'status': status.name,
      'passed': passed,
      'result': mcqResult,
      'session': voiceSession,
      'config': voiceConfig,
      'sessionData': sessionData,
    };
  }

  static InterviewType _parseInterviewType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mcq':
        return InterviewType.mcq;
      case 'voice':
        return InterviewType.voice;
      default:
        return InterviewType.mcq;
    }
  }

  static InterviewDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return InterviewDifficulty.easy;
      case 'medium':
        return InterviewDifficulty.medium;
      case 'hard':
        return InterviewDifficulty.hard;
      default:
        return InterviewDifficulty.medium;
    }
  }

  static InterviewStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return InterviewStatus.completed;
      case 'inprogress':
      case 'in_progress':
        return InterviewStatus.inProgress;
      case 'failed':
        return InterviewStatus.failed;
      default:
        return InterviewStatus.completed;
    }
  }

  static IconData _parseIcon(dynamic icon) {
    if (icon is IconData) return icon;

    // Handle string-based icon names (safer approach)
    if (icon is String) {
      switch (icon.toLowerCase()) {
        case 'quiz':
        case 'quiz_outlined':
          return Icons.quiz_outlined;
        case 'mic':
        case 'microphone':
          return Icons.mic;
        case 'question_answer':
        case 'qa':
          return Icons.question_answer;
        case 'school':
        case 'education':
          return Icons.school;
        case 'voice':
        case 'record_voice_over':
          return Icons.record_voice_over;
        default:
          return Icons.quiz_outlined;
      }
    }

    // For integers, use predefined constant icons instead of creating new IconData
    if (icon is int) {
      // Map common icon code points to their corresponding constant icons
      switch (icon) {
        case 0xe8fd: // Icons.quiz_outlined.codePoint
          return Icons.quiz_outlined;
        case 0xe0b9: // Icons.mic.codePoint
          return Icons.mic;
        case 0xe8f4: // Icons.question_answer.codePoint
          return Icons.question_answer;
        case 0xe625: // Icons.school.codePoint
          return Icons.school;
        default:
          return Icons.quiz_outlined; // Default fallback
      }
    }

    // Default icons based on common types
    return Icons.quiz_outlined;
  }

  String get typeDisplayName {
    switch (type) {
      case InterviewType.mcq:
        return 'MCQ Interview';
      case InterviewType.voice:
        return 'Voice Interview';
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case InterviewDifficulty.easy:
        return 'Easy';
      case InterviewDifficulty.medium:
        return 'Medium';
      case InterviewDifficulty.hard:
        return 'Hard';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case InterviewStatus.completed:
        return 'Completed';
      case InterviewStatus.inProgress:
        return 'In Progress';
      case InterviewStatus.failed:
        return 'Failed';
    }
  }
}

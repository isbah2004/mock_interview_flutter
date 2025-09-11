import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/cubits/usercubit/user_state.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/enums/auth_provider.dart';
import 'package:mock_interview/core/services/user_stats_service.dart';

class UserCubit extends Cubit<UserState> {
  final UserStatsService _userStatsService;

  UserCubit(this._userStatsService) : super(UserInitial());

  UserEntity? get currentUser {
    final state = this.state;
    if (state is UserAvailable) {
      return state.user;
    }
    return null;
  }

  bool get hasUser => state is UserAvailable;

  void loadUser(UserEntity? user) {
    log('Loading user: ${user?.email ?? 'Not Found'}', name: 'UserCubit');
    if (user != null) {
      emit(UserAvailable(user));
      // Store user data to local storage when loaded
      _storeUserToLocalStorage(user);
    } else {
      emit(UserEmpty());
    }
  }

  /// Store user data to local storage
  Future<void> _storeUserToLocalStorage(UserEntity user) async {
    try {
      await _userStatsService.storeUserData(user);
      log(
        'User data stored to local storage: ${user.email}',
        name: 'UserCubit',
      );
    } catch (e) {
      log('Failed to store user data to local storage: $e', name: 'UserCubit');
    }
  }

  void updateUser(UserEntity user) {
    log('Updating user: ${user.email}', name: 'UserCubit');
    emit(UserAvailable(user));
  }

  void clearUser() {
    emit(UserEmpty());
  }

  /// Set error state
  void setError(String message) {
    emit(UserError(message));
  }

  void reset() {
    emit(UserInitial());
  }

  /// Load user data from local storage on app startup
  Future<void> loadUserFromLocalStorage() async {
    try {
      log('Attempting to load user from local storage', name: 'UserCubit');

      final userData = await _userStatsService.getStoredUserData();
      if (userData != null) {
        final user = UserEntity(
          id: userData['id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          photoUrl: userData['photoUrl'],
          provider: _parseAuthProvider(userData['provider']),
          totalInterviews: userData['totalInterviews'] ?? 0,
          voiceInterviews: userData['voiceInterviews'] ?? 0,
          mcqInterviews: userData['mcqInterviews'] ?? 0,
          averageScore: (userData['averageScore'] ?? 0.0).toDouble(),
          createdAt: DateTime.parse(
            userData['createdAt'] ?? DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            userData['updatedAt'] ?? DateTime.now().toIso8601String(),
          ),
        );

        log('Loaded user from local storage: ${user.email}', name: 'UserCubit');
        emit(UserAvailable(user));
      } else {
        log('No user data found in local storage', name: 'UserCubit');
        emit(UserEmpty());
      }
    } catch (e) {
      log('Error loading user from local storage: $e', name: 'UserCubit');
      emit(UserEmpty());
    }
  }

  /// Parse AuthProvider from string
  AuthType _parseAuthProvider(String? providerStr) {
    switch (providerStr) {
      case 'google':
        return AuthType.google;
      case 'facebook':
        return AuthType.facebook;
      case 'email':
      default:
        return AuthType.email;
    }
  }
}

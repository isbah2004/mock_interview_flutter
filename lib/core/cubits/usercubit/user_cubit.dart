import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/cubits/usercubit/user_state.dart';
import 'package:mock_interview/core/entities/user.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  UserEntity? get currentUser {
    final state = this.state;
    if (state is UserAvailable) {
      return state.user;
    }
    return null;
  }

  bool get hasUser => state is UserAvailable;

  void loadUser(UserEntity? user) {
    log( 'Loading user: ${user?.email??'Not Found'}', name: 'UserCubit');
    if (user != null) {

      emit(UserAvailable(user));
    } else {
      emit(UserEmpty());
    }
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
}

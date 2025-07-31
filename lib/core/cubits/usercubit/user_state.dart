import 'package:mock_interview/core/entities/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserAvailable extends UserState {
  final UserEntity user;
  UserAvailable(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAvailable &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

class UserEmpty extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}


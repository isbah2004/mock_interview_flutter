import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/auth/domain/usecases/get_current_user.dart';
import 'package:mock_interview/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_out.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithFacebook signInWithFacebook;
  final UserCubit userCubit;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendPasswordResetEmail,
    required this.signInWithGoogle,
    required this.signInWithFacebook,
    required this.userCubit,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthFacebookSignInRequested>(_onAuthFacebookSignInRequested);
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithGoogle.call(NoParams());
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      userCubit.loadUser(user); // <-- Load user into UserCubit
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onAuthFacebookSignInRequested(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithFacebook.call(NoParams());
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      userCubit.loadUser(user); // <-- Load user into UserCubit
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser.call(NoParams());
    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        log(user.email);
        userCubit.loadUser(user); // <-- Load user into UserCubit
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      userCubit.loadUser(user); // <-- Load user into UserCubit
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      userCubit.loadUser(user); // <-- Load user into UserCubit
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signOut(NoParams());
    result.fold((failure) => emit(AuthError(failure.message)), (_) {
      userCubit.clearUser(); // <-- Clear user from UserCubit
      emit(const AuthUnauthenticated());
    });
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );
    result.fold((failure) => emit(AuthError(failure.message)), (_) {
      emit(const AuthPasswordResetSent());
    });
  }
}

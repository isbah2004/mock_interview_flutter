import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final Account account;

  SplashCubit(this.account) : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    emit(SplashLoading());
    try {
      final user = await account.get();
      emit(SplashAuthenticated(user));
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }
}
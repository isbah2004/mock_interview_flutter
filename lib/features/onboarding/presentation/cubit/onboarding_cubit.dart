import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class OnboardingStarted extends OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class OnboardingCompleted extends OnboardingEvent {}

class OnboardingSkipped extends OnboardingEvent {}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;

  const OnboardingInProgress({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
  });

  @override
  List<Object> get props => [currentPage, totalPages, isLastPage];
}

class OnboardingFinished extends OnboardingState {}

// Cubit
class OnboardingCubit extends Cubit<OnboardingState> {
  static const String _onboardingKey = 'has_seen_onboarding';
  final GetStorage _storage = GetStorage();

  OnboardingCubit() : super(OnboardingInitial());

  void startOnboarding(int totalPages) {
    emit(
      OnboardingInProgress(
        currentPage: 0,
        totalPages: totalPages,
        isLastPage: totalPages == 1,
      ),
    );
  }

  void changePage(int pageIndex, int totalPages) {
    emit(
      OnboardingInProgress(
        currentPage: pageIndex,
        totalPages: totalPages,
        isLastPage: pageIndex == totalPages - 1,
      ),
    );
  }

  void completeOnboarding() {
    _storage.write(_onboardingKey, true);
    emit(OnboardingFinished());
  }

  void skipOnboarding() {
    _storage.write(_onboardingKey, true);
    emit(OnboardingFinished());
  }

  bool hasSeenOnboarding() {
    return _storage.read(_onboardingKey) ?? false;
  }

  void resetOnboarding() {
    _storage.remove(_onboardingKey);
  }
}

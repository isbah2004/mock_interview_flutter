abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationChanged extends NavigationState {
  final int currentIndex;

  NavigationChanged(this.currentIndex);
}

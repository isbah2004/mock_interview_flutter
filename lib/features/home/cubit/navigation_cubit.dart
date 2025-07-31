import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationChanged(0));

  void changeTab(int index) {
    emit(NavigationChanged(index));
  }

  int get currentIndex {
    final state = this.state;
    if (state is NavigationChanged) {
      return state.currentIndex;
    }
    return 0;
  }
}

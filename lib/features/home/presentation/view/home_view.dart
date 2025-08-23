import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/history.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/home.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/profile.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/settings.dart';
import 'package:mock_interview/features/home/presentation/widgets/custom_bottom_navigation.dart';
import '../../cubit/navigation_cubit.dart';
import '../../cubit/navigation_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final List<Widget> _tabs = [
    const HomeTab(),
    const HistoryTab(),
    const ProfileTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          final currentIndex = context.read<NavigationCubit>().currentIndex;

          return Scaffold(
            body: IndexedStack(index: currentIndex, children: _tabs),
            bottomNavigationBar: const BottomNavigation(),
          );
        },
      ),
    );
  }
}

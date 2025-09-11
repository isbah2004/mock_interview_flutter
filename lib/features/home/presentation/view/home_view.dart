import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/history.dart';
import 'package:mock_interview/features/history/presentation/cubit/history_cubit.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/home.dart';
import 'package:mock_interview/features/home/presentation/view/tabs/profile_settings.dart';
import 'package:mock_interview/features/home/presentation/widgets/custom_bottom_navigation.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import '../../cubit/navigation_cubit.dart';
import '../../cubit/navigation_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final List<Widget> _tabs = [
    HomeTab(),
    // Provide HistoryCubit locally to ensure it's always in scope (avoids hot-reload provider issues)
    BlocProvider<HistoryCubit>(
      create: (_) => serviceLocator<HistoryCubit>(),
      child: const HistoryTab(),
    ),
    const ProfileSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // NavigationCubit should be provided at app-level (main.dart) via DI.
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final currentIndex = context.read<NavigationCubit>().currentIndex;

        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _tabs),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}

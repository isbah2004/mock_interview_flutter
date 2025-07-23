import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/navigation_cubit.dart';
import '../../cubit/navigation_state.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'tabs/home.dart';
import 'tabs/history.dart';
import 'tabs/profile.dart';
import 'tabs/settings.dart';

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
            bottomNavigationBar: const CustomBottomNavigation(),
          );
        },
      ),
    );
  }
}

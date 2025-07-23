import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import '../../cubit/navigation_cubit.dart';
import '../../cubit/navigation_state.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final currentIndex = context.read<NavigationCubit>().currentIndex;

        return SizedBox(
          height: 70,
          child: DotNavigationBar(
            backgroundColor: theme.colorScheme.surface,
            currentIndex: currentIndex,

            paddingR: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            marginR: const EdgeInsets.symmetric(horizontal: 1),
            margin: EdgeInsets.all(8),
            borderRadius: 12,
            onTap: (index) {
              context.read<NavigationCubit>().changeTab(index);
            },
            items: [
              DotNavigationBarItem(icon: const Icon(Icons.home)),
              DotNavigationBarItem(icon: const Icon(Icons.description)),
              DotNavigationBarItem(icon: const Icon(Icons.person)),
              DotNavigationBarItem(icon: const Icon(Icons.settings)),
            ],
          ),
        );
      },
    );
  }
}

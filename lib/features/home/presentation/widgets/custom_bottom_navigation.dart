import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import '../../cubit/navigation_cubit.dart';
import '../../cubit/navigation_state.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final currentIndex = context.read<NavigationCubit>().currentIndex;

        final iconList = <IconData>[
          Icons.home_rounded,
          Icons.description_rounded,
          Icons.person_rounded,
        ];

        return AnimatedBottomNavigationBar(
          icons: iconList,
          activeIndex: currentIndex,
          onTap: (index) {
            context.read<NavigationCubit>().changeTab(index);
          },
          // Styling
          backgroundColor: theme.colorScheme.surface,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.onSurface.withOpacityCompat(0.5),
          splashColor: theme.colorScheme.primary.withOpacityCompat(0.2),
          splashRadius: 24,

          // Fluid animations
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.smoothEdge,
          leftCornerRadius: 20,
          rightCornerRadius: 20,

          // Visual enhancements
          iconSize: 24,
          height: 65,
          elevation: 8,
          shadow: BoxShadow(
            color: theme.colorScheme.primary.withOpacityCompat(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        );
      },
    );
  }
}

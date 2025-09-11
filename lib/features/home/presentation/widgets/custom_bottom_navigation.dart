import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
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

        return
        // Container(
        //   height: 60,
        //   margin: const EdgeInsets.only(left: 8, right: 8, top: 0),
        //   decoration: BoxDecoration(
        //     color: theme.colorScheme.onPrimary,
        //     borderRadius: BorderRadius.circular(20),
        //     boxShadow: [
        //       BoxShadow(
        //         color: theme.colorScheme.primary.withOpacity(0.1),
        //         blurRadius: 20,
        //         offset: const Offset(0, 8),
        //       ),
        //     ],
        //   ),
        // child:
        DotNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          currentIndex: currentIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacityCompat(
            0.5,
          ),
          // paddingR: EdgeInsets.only(
          //     bottom: context.height * 0.005, top: context.height * 0.005),
          marginR: const EdgeInsets.symmetric(horizontal: 1),
          // margin: EdgeInsets.only(
          //     left: context.width * 0.05, right: context.width * 0.05),
          paddingR: const EdgeInsets.symmetric(vertical: 4),

          borderRadius: 20,
          onTap: (index) {
            context.read<NavigationCubit>().changeTab(index);
          },
          items: [
            DotNavigationBarItem(icon: const Icon(Icons.home_rounded)),
            DotNavigationBarItem(icon: const Icon(Icons.description_rounded)),
            DotNavigationBarItem(icon: const Icon(Icons.person_rounded)),
          ],
          // ),
        );
      },
    );
  }
}

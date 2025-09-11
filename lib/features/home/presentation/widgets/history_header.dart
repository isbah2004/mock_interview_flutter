import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_stat_card.dart';
import 'package:mock_interview/features/home/data/models/history_stat_model.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/cubits/usercubit/user_state.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        double averageScore = 0.0;
        int totalInterviews = 0;

        if (state is UserAvailable) {
          averageScore = state.user.averageScore;
          totalInterviews = state.user.totalInterviews;
        }

        final stats = [
          HistoryStatModel(
            value: averageScore.toStringAsFixed(0),
            label: 'Avg Score',
            icon: Icons.emoji_events_rounded,
            isPrimary: true,
          ),
          HistoryStatModel(
            value: totalInterviews.toString(),
            label: 'Interviews',
            icon: Icons.calendar_today_rounded,
            isPrimary: false,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Interview History',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children:
                    stats.asMap().entries.map((entry) {
                      final stat = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: HistoryStatCard.fromModel(model: stat),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

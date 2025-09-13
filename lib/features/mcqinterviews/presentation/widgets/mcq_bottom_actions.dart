import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_bloc.dart';

class McqBottomActions extends StatelessWidget {
  final McqInterviewInProgressState state;

  const McqBottomActions({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          if (state.canNavigatePrevious)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<McqInterviewBloc>().add(
                    const NavigateToPrevious(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Previous',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          if (state.canNavigatePrevious) const SizedBox(width: 16),
          Expanded(
            flex: state.canNavigatePrevious ? 1 : 2,
            child: ElevatedButton(
              onPressed:
                  state.canNavigateNext
                      ? () {
                        if (state.isLastQuestion) {
                          context.read<McqInterviewBloc>().add(
                            const CompleteInterview(),
                          );
                        } else {
                          context.read<McqInterviewBloc>().add(
                            const NavigateToNext(),
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                state.isLastQuestion ? 'Submit Interview' : 'Next Question',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

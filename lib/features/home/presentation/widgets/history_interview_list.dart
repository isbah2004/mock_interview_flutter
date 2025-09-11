import 'package:flutter/material.dart';
import 'package:mock_interview/features/home/data/models/interview_history_model.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_interview_card.dart';

class HistoryInterviewList extends StatelessWidget {
  final List<InterviewHistoryModel> interviewHistory;

  const HistoryInterviewList({super.key, required this.interviewHistory});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: interviewHistory.length,
      itemBuilder: (context, index) {
        final interview = interviewHistory[index];
        return HistoryInterviewCard(interview: interview);
      },
    );
  }
}

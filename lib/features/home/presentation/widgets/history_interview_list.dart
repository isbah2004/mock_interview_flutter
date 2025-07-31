import 'package:flutter/material.dart';
import 'history_interview_card.dart';

class HistoryInterviewList extends StatelessWidget {
  final List<Map<String, dynamic>> interviewHistory;

  const HistoryInterviewList({super.key, required this.interviewHistory});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: interviewHistory.length,
        itemBuilder: (context, index) {
          final interview = interviewHistory[index];
          return HistoryInterviewCard(interview: interview);
        },
      ),
    );
  }
}

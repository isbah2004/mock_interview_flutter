import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../../../../../core/services/session_manager.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool isLoading = false;
  List<Map<String, dynamic>> interviewHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Get actual user ID from AuthBloc or context
      const String currentUserId =
          'current_user_id'; // Replace with actual user ID

      // Get user sessions from database
      final sessions = await SessionManager.getUserSessions(currentUserId);

      // Convert to display format
      final historyList =
          sessions.map((session) {
            return SessionManager.sessionToDisplayFormat(session);
          }).toList();

      if (!mounted) return;
      setState(() {
        interviewHistory = historyList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            const HistoryHeader(),

            // Content
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : interviewHistory.isEmpty
                      ? _buildEmptyState()
                      : HistoryInterviewList(
                        interviewHistory: interviewHistory,
                      ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No interview history yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first interview to see it here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadHistory, child: const Text('Refresh')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/constants/database_constants.dart';

class ResultsHistoryView extends StatefulWidget {
  const ResultsHistoryView({super.key});

  @override
  State<ResultsHistoryView> createState() => _ResultsHistoryViewState();
}

class _ResultsHistoryViewState extends State<ResultsHistoryView> {
  late UnifiedDatabaseService _databaseService;
  late Future<List<UnifiedInterviewSession>> _sessionsFuture;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Initialize database service - you'll need to inject Databases instance
    // For now, using a placeholder - this should be injected via DI
    _databaseService = UnifiedDatabaseService(databases: Databases(Client()));
    _loadSessions();
  }

  void _loadSessions() {
    // Get user ID from your user management system
    const userId = 'current-user-id'; // Replace with actual user ID

    _sessionsFuture = _databaseService.getUserInterviewSessions(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: FutureBuilder<List<UnifiedInterviewSession>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading results: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loadSessions();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final sessions = snapshot.data ?? [];

                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No interview results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete some interviews to see your results here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder:
                      (context, index) => _buildSessionCard(sessions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('all', 'All'),
          const SizedBox(width: 8),
          _buildFilterChip(DatabaseConstants.interviewTypeMCQ, 'MCQ'),
          const SizedBox(width: 8),
          _buildFilterChip(DatabaseConstants.interviewTypeVoice, 'Voice'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
            _loadSessions();
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }

  Widget _buildSessionCard(UnifiedInterviewSession session) {
    final isPassed = session.passed ?? false;
    final score = session.score ?? 0.0;
    final percentage = session.percentage ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewSessionDetails(session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          session.interviewType ==
                                  DatabaseConstants.interviewTypeMCQ
                              ? Colors.blue[100]
                              : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      session.interviewType ==
                              DatabaseConstants.interviewTypeMCQ
                          ? Icons.quiz
                          : Icons.mic,
                      color:
                          session.interviewType ==
                                  DatabaseConstants.interviewTypeMCQ
                              ? Colors.blue[700]
                              : Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.jobRole,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${session.category} • ${session.difficulty}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPassed ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isPassed ? 'Passed' : 'Failed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPassed ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem('Score', score.toStringAsFixed(1)),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    'Percentage',
                    '${percentage.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem('Questions', '${session.totalQuestions}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Completed: ${_formatDate(session.completedAt ?? session.startedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _viewSessionDetails(UnifiedInterviewSession session) {
    if (session.interviewType == DatabaseConstants.interviewTypeMCQ) {
      // Navigate to MCQ results detail
      Navigator.pushNamed(
        context,
        '/mcq-result-detail',
        arguments: session.sessionId,
      );
    } else {
      // Navigate to Voice results detail with transcript
      Navigator.pushNamed(
        context,
        '/voice-result-detail',
        arguments: session.sessionId,
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

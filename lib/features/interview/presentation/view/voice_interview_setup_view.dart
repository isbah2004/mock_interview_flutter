import 'package:flutter/material.dart';
import 'package:mock_interview/core/navigation/navigation_service.dart';

class VoiceInterviewSetupScreen extends StatefulWidget {
  const VoiceInterviewSetupScreen({Key? key}) : super(key: key);

  @override
  State<VoiceInterviewSetupScreen> createState() => _VoiceInterviewSetupScreenState();
}

class _VoiceInterviewSetupScreenState extends State<VoiceInterviewSetupScreen> {
  String selectedDifficulty = 'Medium';
  String selectedDuration = '15 min';
  String selectedCategory = 'General';
  bool microphonePermission = false;

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> durations = ['10 min', '15 min', '20 min', '30 min'];
  final List<String> categories = ['General', 'Technical', 'Behavioral', 'Leadership'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9FAFB),
              Colors.white,
              Color(0xFFF3F4F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF374151),
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Voice Interview Setup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Microphone Check
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF111827), Color(0xFF374151)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Microphone Access',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Required for voice responses',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: microphonePermission,
                              onChanged: (value) {
                                setState(() => microphonePermission = value);
                              },
                              activeColor: Colors.white,
                              activeTrackColor: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Interview Settings
                      const Text(
                        'Interview Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Difficulty
                      _buildSettingCard(
                        'Difficulty Level',
                        'Choose your preferred difficulty',
                        Icons.trending_up,
                        difficulties,
                        selectedDifficulty,
                        (value) => setState(() => selectedDifficulty = value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Duration
                      _buildSettingCard(
                        'Duration',
                        'How long should the interview last?',
                        Icons.access_time,
                        durations,
                        selectedDuration,
                        (value) => setState(() => selectedDuration = value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Category
                      _buildSettingCard(
                        'Category',
                        'Select interview focus area',
                        Icons.category,
                        categories,
                        selectedCategory,
                        (value) => setState(() => selectedCategory = value),
                      ),
                      const SizedBox(height: 32),
                      
                      // Interview Preview
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.preview, color: Color(0xFF374151), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Interview Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildPreviewItem('Difficulty', selectedDifficulty),
                            _buildPreviewItem('Duration', selectedDuration),
                            _buildPreviewItem('Category', selectedCategory),
                            _buildPreviewItem('Questions', '5-7 questions'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Start Interview Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          // onPressed: microphonePermission ? () {
                          //   NavigationService.navigateToVoiceInterview();
                          // } : null,
                          onPressed: (){ NavigationService.navigateToVoiceInterview();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: microphonePermission 
                                    ? [Color(0xFF111827), Colors.black]
                                    : [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Start Voice Interview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    IconData icon,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF374151), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
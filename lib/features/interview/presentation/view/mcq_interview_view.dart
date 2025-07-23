import 'package:flutter/material.dart';
import 'dart:async';

class MCQInterviewScreen extends StatefulWidget {
  const MCQInterviewScreen({Key? key}) : super(key: key);

  @override
  State<MCQInterviewScreen> createState() => _MCQInterviewScreenState();
}

class _MCQInterviewScreenState extends State<MCQInterviewScreen>
    with TickerProviderStateMixin {
  int currentQuestion = 0;
  int totalQuestions = 10;
  int timeRemaining = 30;
  int? selectedAnswer;
  Timer? questionTimer;
  late AnimationController _progressController;
  
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the primary purpose of a job interview?',
      'options': [
        'To negotiate salary',
        'To assess mutual fit between candidate and company',
        'To test technical skills only',
        'To complete paperwork'
      ],
      'correct': 1,
    },
    {
      'question': 'Which of the following is the best way to answer "Tell me about yourself"?',
      'options': [
        'Share personal life details',
        'Recite your entire resume',
        'Give a brief professional summary with relevant achievements',
        'Ask the interviewer about themselves first'
      ],
      'correct': 2,
    },
    {
      'question': 'What should you do if you don\'t know the answer to a technical question?',
      'options': [
        'Make up an answer',
        'Stay silent and move on',
        'Admit you don\'t know and explain how you would find the answer',
        'Change the subject'
      ],
      'correct': 2,
    },
    {
      'question': 'How should you prepare for behavioral interview questions?',
      'options': [
        'Memorize generic answers',
        'Use the STAR method with specific examples',
        'Keep answers very brief',
        'Focus only on positive experiences'
      ],
      'correct': 1,
    },
    {
      'question': 'What is the best time to ask about salary and benefits?',
      'options': [
        'At the beginning of the first interview',
        'After receiving a job offer',
        'During the middle of the interview',
        'In the follow-up email'
      ],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _progressController.dispose();
    questionTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    timeRemaining = 30;
    _progressController.reset();
    _progressController.forward();
    
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
      });
      
      if (timeRemaining <= 0) {
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
    });
  }

  void _nextQuestion() {
    questionTimer?.cancel();
    
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
      _startQuestionTimer();
    } else {
      Navigator.pushReplacementNamed(context, '/interview-results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showExitDialog(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF374151),
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          'Question ${currentQuestion + 1} of ${questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: timeRemaining <= 10 
                                ? const LinearGradient(colors: [Colors.red, Color(0xFFDC2626)])
                                : const LinearGradient(colors: [Color(0xFF374151), Color(0xFF4B5563)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${timeRemaining}s',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress Bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1 - _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: timeRemaining <= 10 
                                      ? [Colors.red, Color(0xFFDC2626)]
                                      : [Color(0xFF374151), Color(0xFF4B5563)],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF374151), Color(0xFF4B5563)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.quiz,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Question',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              question['question'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Answer Options
                      Expanded(
                        child: ListView.builder(
                          itemCount: question['options'].length,
                          itemBuilder: (context, index) {
                            final isSelected = selectedAnswer == index;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => _selectAnswer(index),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF111827) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index), // A, B, C, D
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          question['options'][index],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Next Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ElevatedButton(
                          onPressed: selectedAnswer != null ? _nextQuestion : null,
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
                                colors: selectedAnswer != null 
                                    ? [Color(0xFF374151), Color(0xFF4B5563)]
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
                            child: Center(
                              child: Text(
                                currentQuestion < questions.length - 1 ? 'Next Question' : 'Finish Interview',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit Interview?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: const Text(
            'Are you sure you want to exit? Your progress will be lost.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
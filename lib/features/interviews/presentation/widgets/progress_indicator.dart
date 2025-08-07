import 'package:flutter/material.dart';

class InterviewProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  final double progress;
  final Duration? timeRemaining;

  const InterviewProgressIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.progress,
    this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 6,
          ),

          // Timer if provided
          if (timeRemaining != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _getTimeColor(timeRemaining!),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(timeRemaining!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getTimeColor(timeRemaining!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTimeColor(Duration duration) {
    if (duration.inSeconds <= 10) {
      return Colors.red;
    } else if (duration.inSeconds <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

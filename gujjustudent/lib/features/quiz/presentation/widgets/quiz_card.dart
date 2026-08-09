import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onStart;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (quiz.isNew)
                  _buildBadge("NEW", Colors.orange.withValues(alpha: 0.12), Colors.orange)
                else if (quiz.retakeAvailable && quiz.usedAttempts > 0)
                  _buildBadge("RETAKE", Colors.blue.withValues(alpha: 0.1), const Color(0xFF1565C0)),
              ],
            ),
            const SizedBox(height: 10),
            // Info Row
            _buildInfoRow(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            // Bottom row: Attempts & Start Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAttemptsInfo(),
                _buildStartButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildIconInfo(Icons.help_outline_rounded, "${quiz.totalQuestions} MCQs"),
        const SizedBox(width: 16),
        _buildIconInfo(Icons.timer_outlined, quiz.durationString),
        const SizedBox(width: 16),
        _buildDifficultyBadge(),
      ],
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    String label;

    switch (quiz.difficulty) {
      case QuizDifficulty.easy:
        color = Colors.green;
        label = "Easy";
        break;
      case QuizDifficulty.medium:
        color = Colors.orange;
        label = "Medium";
        break;
      case QuizDifficulty.hard:
        color = Colors.red;
        label = "Hard";
        break;
    }

    return Row(
      children: [
        Icon(Icons.bar_chart_rounded, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptsInfo() {
    return Text(
      "Attempts: ${quiz.usedAttempts}/${quiz.maxAttempts}",
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStartButton() {
    final bool canStart = quiz.retakeAvailable;
    return ElevatedButton(
      onPressed: canStart ? onStart : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canStart ? AppColors.primary : Colors.grey[300],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: const Text(
        "Start Quiz",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

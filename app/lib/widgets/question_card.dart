import 'package:flutter/material.dart';
import '../../models/lesson_pack.dart';
import '../../services/audio_service.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showHint;
  final bool answerSubmitted;
  final String? correctAnswer;
  final ValueChanged<String> onAnswer;
  final VoidCallback onListen;
  final VoidCallback? onListenHint;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.showHint,
    required this.answerSubmitted,
    required this.correctAnswer,
    required this.onAnswer,
    required this.onListen,
    this.onListenHint,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == question.correctAnswer;
    final isWrong = answerSubmitted && selectedAnswer != null && !isCorrect;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with listen button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _difficultyColor(question.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.difficulty.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor(question.difficulty),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onListen,
                  icon: const Icon(Icons.volume_up, color: Color(0xFF2E7D32)),
                  tooltip: 'Listen to question',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question text
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Options
            ...question.options.map((option) => _buildOption(option, isCorrect, isWrong)).toList(),

            // Hint section
            if (showHint) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Hint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700],
                          ),
                        ),
                        const Spacer(),
                        if (onListenHint != null)
                          IconButton(
                            onPressed: onListenHint,
                            icon: Icon(Icons.volume_up, color: Colors.amber[700]),
                            tooltip: 'Listen to hint',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Think of two pieces of the same-sized pizza. When you put them together, how much do you have?',
                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                    ),
                  ],
                ),
              ),
            ],

            // Feedback after submission
            if (answerSubmitted && selectedAnswer != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isCorrect ? Colors.green[200]! : Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green[700] : Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCorrect
                            ? 'Correct! Well done! 🎉'
                            : 'Not quite. The answer is $correctAnswer. $showHint ? "Listen to the hint above." : "Try the next one!"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCorrect ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, bool isCorrect, bool isWrong) {
    final isSelected = selectedAnswer == option;
    final showCorrect = answerSubmitted && option == correctAnswer;

    Color? bgColor;
    Color? borderColor;
    Color? textColor;
    IconData? trailingIcon;

    if (showCorrect) {
      bgColor = Colors.green[50];
      borderColor = Colors.green[400];
      textColor = Colors.green[800];
      trailingIcon = Icons.check_circle;
    } else if (isSelected && isWrong) {
      bgColor = Colors.red[50];
      borderColor = Colors.red[400];
      textColor = Colors.red[800];
      trailingIcon = Icons.cancel;
    } else if (isSelected) {
      bgColor = const Color(0xFF2E7D32).withOpacity(0.1);
      borderColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey[300];
      textColor = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: answerSubmitted ? null : () => onAnswer(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor!, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: borderColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const Color(0xFF2E7D32);
      case 'medium':
        return Colors.amber[700]!;
      case 'hard':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }
}
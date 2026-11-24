import '../models/mastery_event.dart';
import 'db_service.dart';

class AdaptiveEngine {
  static const double initialMastery = 0.50;
  static const double correctIncrement = 0.12;
  static const double wrongDecrement = 0.18;
  static const double masteryThreshold = 0.80;
  static const double revisionThreshold = 0.40;

  final DbService _db = DbService();

  /// Calculate new mastery after an answer
  double calculateMastery(double currentMastery, bool isCorrect) {
    if (isCorrect) {
      return (currentMastery + correctIncrement).clamp(0.0, 1.0);
    } else {
      return (currentMastery - wrongDecrement).clamp(0.0, 1.0);
    }
  }

  /// Determine next difficulty based on recent performance
  String getNextDifficulty(String skillId, String studentId, List<bool> recentAnswers) {
    if (recentAnswers.length < 2) return 'medium';

    final lastTwo = recentAnswers.take(2).toList();
    if (lastTwo.every((a) => a)) {
      return 'hard';
    } else if (lastTwo.every((a) => !a)) {
      return 'easy';
    }
    return 'medium';
  }

  /// Check if skill is mastered
  bool isMastered(double mastery) => mastery >= masteryThreshold;

  /// Check if skill needs revision
  bool needsRevision(double mastery) => mastery < revisionThreshold;

  /// Process an answer and return the event + next action
  Future<AdaptiveResult> processAnswer({
    required String studentId,
    required String skillId,
    required String questionId,
    required bool isCorrect,
  }) async {
    final currentMastery = await _db.getMastery(studentId, skillId);
    final newMastery = calculateMastery(currentMastery, isCorrect);

    await _db.setMastery(studentId, skillId, newMastery);

    final event = MasteryEvent(
      eventId: DateTime.now().microsecondsSinceEpoch.toString(),
      studentId: studentId,
      skillId: skillId,
      questionId: questionId,
      isCorrect: isCorrect,
      masteryBefore: currentMastery,
      masteryAfter: newMastery,
      timestamp: DateTime.now(),
    );

    await _db.addSyncEvent(event);

    // Get recent answers for this skill to determine next difficulty
    // In a real app, you'd query the sync_queue for recent answers
    // For demo, we'll use a simple heuristic
    String nextDifficulty = 'medium';
    bool showHint = false;
    bool isMasteredNow = isMastered(newMastery);
    bool needsRevisionNow = needsRevision(newMastery);

    if (!isCorrect) {
      // Check if this is 2nd wrong in a row (simplified)
      showHint = true;
      nextDifficulty = 'easy';
    } else if (isCorrect && newMastery > 0.7) {
      nextDifficulty = 'hard';
    }

    return AdaptiveResult(
      event: event,
      newMastery: newMastery,
      nextDifficulty: nextDifficulty,
      showHint: showHint,
      isMastered: isMasteredNow,
      needsRevision: needsRevisionNow,
    );
  }

  /// Get all mastery scores for a student (for teacher dashboard sync)
  Future<Map<String, double>> getStudentMastery(String studentId) async {
    return await _db.getAllMastery(studentId);
  }
}

class AdaptiveResult {
  final MasteryEvent event;
  final double newMastery;
  final String nextDifficulty;
  final bool showHint;
  final bool isMastered;
  final bool needsRevision;

  AdaptiveResult({
    required this.event,
    required this.newMastery,
    required this.nextDifficulty,
    required this.showHint,
    required this.isMastered,
    required this.needsRevision,
  });
}
class MasteryEvent {
  final String eventId;
  final String studentId;
  final String skillId;
  final String questionId;
  final bool isCorrect;
  final double masteryBefore;
  final double masteryAfter;
  final DateTime timestamp;
  final bool synced;

  MasteryEvent({
    required this.eventId,
    required this.studentId,
    required this.skillId,
    required this.questionId,
    required this.isCorrect,
    required this.masteryBefore,
    required this.masteryAfter,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'student_id': studentId,
      'skill_id': skillId,
      'question_id': questionId,
      'is_correct': isCorrect ? 1 : 0,
      'mastery_before': masteryBefore,
      'mastery_after': masteryAfter,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory MasteryEvent.fromMap(Map<String, dynamic> map) {
    return MasteryEvent(
      eventId: map['event_id'],
      studentId: map['student_id'],
      skillId: map['skill_id'],
      questionId: map['question_id'],
      isCorrect: map['is_correct'] == 1,
      masteryBefore: map['mastery_before'].toDouble(),
      masteryAfter: map['mastery_after'].toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'studentId': studentId,
        'skillId': skillId,
        'questionId': questionId,
        'isCorrect': isCorrect,
        'masteryBefore': masteryBefore,
        'masteryAfter': masteryAfter,
        'timestamp': timestamp.toIso8601String(),
      };
}
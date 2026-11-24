class LessonPack {
  final String packId;
  final int grade;
  final String subject;
  final String language;
  final List<String> skills;
  final List<Lesson> lessons;

  LessonPack({
    required this.packId,
    required this.grade,
    required this.subject,
    required this.language,
    required this.skills,
    required this.lessons,
  });

  factory LessonPack.fromJson(Map<String, dynamic> json) {
    return LessonPack(
      packId: json['packId'],
      grade: json['grade'],
      subject: json['subject'],
      language: json['language'],
      skills: List<String>.from(json['skills']),
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String narrationAudio;
  final String visualAsset;
  final List<String> questionIds;

  Lesson({
    required this.id,
    required this.title,
    required this.narrationAudio,
    required this.visualAsset,
    required this.questionIds,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      narrationAudio: json['narration'],
      visualAsset: json['visual'],
      questionIds: List<String>.from(json['questions']),
    );
  }
}

class Question {
  final String id;
  final String skillId;
  final String difficulty; // easy, medium, hard
  final String questionText;
  final String questionAudio;
  final List<String> options;
  final String correctAnswer;
  final String hintAudio;
  final String hintVisual;

  Question({
    required this.id,
    required this.skillId,
    required this.difficulty,
    required this.questionText,
    required this.questionAudio,
    required this.options,
    required this.correctAnswer,
    required this.hintAudio,
    required this.hintVisual,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      skillId: json['skillId'],
      difficulty: json['difficulty'],
      questionText: json['questionText'],
      questionAudio: json['questionAudio'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      hintAudio: json['hintAudio'],
      hintVisual: json['hintVisual'],
    );
  }
}
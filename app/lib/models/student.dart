class Student {
  final String id;
  final String name;
  final String avatarPath;
  final String pin;
  final int grade;
  final String language;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.pin,
    required this.grade,
    required this.language,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar_path': avatarPath,
      'pin': pin,
      'grade': grade,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      avatarPath: map['avatar_path'],
      pin: map['pin'],
      grade: map['grade'],
      language: map['language'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
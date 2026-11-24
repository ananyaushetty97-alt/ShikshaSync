import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/mastery_event.dart';
import '../models/lesson_pack.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shikshasync.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_path TEXT NOT NULL,
        pin TEXT NOT NULL,
        grade INTEGER NOT NULL,
        language TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mastery_scores (
        student_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        mastery REAL NOT NULL DEFAULT 0.5,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (student_id, skill_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        event_id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        mastery_before REAL NOT NULL,
        mastery_after REAL NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE lesson_packs (
        pack_id TEXT PRIMARY KEY,
        grade INTEGER NOT NULL,
        subject TEXT NOT NULL,
        language TEXT NOT NULL,
        skills TEXT NOT NULL,
        lessons TEXT NOT NULL,
        downloaded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        question_id TEXT PRIMARY KEY,
        pack_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        question_text TEXT NOT NULL,
        question_audio TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        hint_audio TEXT NOT NULL,
        hint_visual TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_synced ON sync_queue(synced)
    ''');
    await db.execute('''
      CREATE INDEX idx_mastery_student ON mastery_scores(student_id)
    ''');
  }

  // Student operations
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  Future<Student?> getStudentByPin(String pin) async {
    final db = await database;
    final maps = await db.query('students', where: 'pin = ?', whereArgs: [pin]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<Student?> getStudentById(String id) async {
    final db = await database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  // Mastery operations
  Future<double> getMastery(String studentId, String skillId) async {
    final db = await database;
    final maps = await db.query(
      'mastery_scores',
      where: 'student_id = ? AND skill_id = ?',
      whereArgs: [studentId, skillId],
    );
    if (maps.isEmpty) return 0.5;
    return maps.first['mastery'] as double;
  }

  Future<void> setMastery(String studentId, String skillId, double mastery) async {
    final db = await database;
    await db.insert(
      'mastery_scores',
      {
        'student_id': studentId,
        'skill_id': skillId,
        'mastery': mastery.clamp(0.0, 1.0),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, double>> getAllMastery(String studentId) async {
    final db = await database;
    final maps = await db.query(
      'mastery_scores',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return {for (var m in maps) m['skill_id'] as String: m['mastery'] as double};
  }

  // Sync queue operations
  Future<void> addSyncEvent(MasteryEvent event) async {
    final db = await database;
    await db.insert('sync_queue', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MasteryEvent>> getUnsyncedEvents() async {
    final db = await database;
    final maps = await db.query(
      'sync_queue',
      where: 'synced = 0',
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => MasteryEvent.fromMap(m)).toList();
  }

  Future<void> markEventsSynced(List<String> eventIds) async {
    if (eventIds.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final id in eventIds) {
      batch.update(
        'sync_queue',
        {'synced': 1},
        where: 'event_id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  // Lesson pack operations
  Future<void> insertLessonPack(LessonPack pack) async {
    final db = await database;
    await db.insert(
      'lesson_packs',
      {
        'pack_id': pack.packId,
        'grade': pack.grade,
        'subject': pack.subject,
        'language': pack.language,
        'skills': pack.skills.join(','),
        'lessons': pack.lessons.map((l) => l.id).join(','),
        'downloaded_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LessonPack?> getLessonPack(String packId) async {
    final db = await database;
    final maps = await db.query(
      'lesson_packs',
      where: 'pack_id = ?',
      whereArgs: [packId],
    );
    if (maps.isEmpty) return null;
    // For simplicity, we'd reconstruct from assets in real app
    return null;
  }

  // Question operations
  Future<void> insertQuestions(String packId, List<Question> questions) async {
    final db = await database;
    final batch = db.batch();
    for (final q in questions) {
      batch.insert(
        'questions',
        {
          'question_id': q.id,
          'pack_id': packId,
          'skill_id': q.skillId,
          'difficulty': q.difficulty,
          'question_text': q.questionText,
          'question_audio': q.questionAudio,
          'options': q.options.join('|'),
          'correct_answer': q.correctAnswer,
          'hint_audio': q.hintAudio,
          'hint_visual': q.hintVisual,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Question?> getQuestion(String questionId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    if (maps.isEmpty) return null;
    final m = maps.first;
    return Question(
      id: m['question_id'] as String,
      skillId: m['skill_id'] as String,
      difficulty: m['difficulty'] as String,
      questionText: m['question_text'] as String,
      questionAudio: m['question_audio'] as String,
      options: (m['options'] as String).split('|'),
      correctAnswer: m['correct_answer'] as String,
      hintAudio: m['hint_audio'] as String,
      hintVisual: m['hint_visual'] as String,
    );
  }

  Future<List<Question>> getQuestionsForSkill(String skillId, {String? difficulty}) async {
    final db = await database;
    String where = 'skill_id = ?';
    List<dynamic> args = [skillId];
    if (difficulty != null) {
      where += ' AND difficulty = ?';
      args.add(difficulty);
    }
    final maps = await db.query('questions', where: where, whereArgs: args);
    return maps.map((m) => Question(
      id: m['question_id'] as String,
      skillId: m['skill_id'] as String,
      difficulty: m['difficulty'] as String,
      questionText: m['question_text'] as String,
      questionAudio: m['question_audio'] as String,
      options: (m['options'] as String).split('|'),
      correctAnswer: m['correct_answer'] as String,
      hintAudio: m['hint_audio'] as String,
      hintVisual: m['hint_visual'] as String,
    )).toList();
  }
}
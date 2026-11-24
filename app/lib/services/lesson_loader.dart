import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson_pack.dart';
import '../models/mastery_event.dart';
import 'db_service.dart';

/// Service to load lesson packs from local assets and populate the database
class LessonLoader {
  static final LessonLoader _instance = LessonLoader._internal();
  factory LessonLoader() => _instance;
  LessonLoader._internal();

  final DbService _db = DbService();

  /// Load a lesson pack from assets and store in database
  Future<LessonPack?> loadPackFromAssets(String packPath) async {
    try {
      // Load lesson.json
      final lessonJson = await rootBundle.loadString('$packPath/lesson.json');
      final lessonData = jsonDecode(lessonJson) as Map<String, dynamic>;

      // Load quiz.json
      final quizJson = await rootBundle.loadString('$packPath/quiz.json');
      final quizData = jsonDecode(quizJson) as Map<String, dynamic>;

      // Parse LessonPack
      final pack = LessonPack.fromJson(lessonData);

      // Parse Questions
      final questions = (quizData['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();

      // Store in database
      await _db.insertLessonPack(pack);
      await _db.insertQuestions(pack.packId, questions);

      return pack;
    } catch (e) {
      print('Error loading lesson pack from $packPath: $e');
      return null;
    }
  }

  /// Load all available lesson packs from assets manifest
  Future<List<LessonPack>> loadAllPacks() async {
    try {
      final manifestJson = await rootBundle.loadString('assets/lessons/manifest.json');
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
      final packs = <LessonPack>[];

      for (final packInfo in manifest['packs'] as List) {
        final packPath = packInfo['path'] as String;
        final pack = await loadPackFromAssets(packPath);
        if (pack != null) {
          packs.add(pack);
        }
      }
      return packs;
    } catch (e) {
      print('Error loading manifest: $e');
      return [];
    }
  }

  /// Get a specific lesson pack by ID (loads from assets if not in DB)
  Future<LessonPack?> getLessonPack(String packId) async {
    // First try to get from DB (already downloaded)
    final cached = await _db.getLessonPack(packId);
    if (cached != null) return cached;

    // Otherwise try to load from assets
    return await loadPackFromAssets('assets/lessons/$packId');
  }

  /// Get questions for a lesson
  Future<List<Question>> getQuestionsForLesson(String packId, String lessonId) async {
    // In a real app, you'd query questions by lesson_id
    // For now, return all questions for the pack
    final questions = <Question>[];
    // This would need a proper query - simplified for demo
    return questions;
  }
}
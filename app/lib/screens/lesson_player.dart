import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/student.dart';
import '../../models/lesson_pack.dart';
import '../../models/mastery_event.dart';
import '../../services/db_service.dart';
import '../../services/adaptive_engine.dart';
import '../../services/audio_service.dart';
import '../../services/sync_service.dart';
import '../../services/lesson_loader.dart';
import '../widgets/question_card.dart';
import '../widgets/listen_button.dart';
import '../widgets/offline_badge.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Student student;
  const LessonPlayerScreen({super.key, required this.student});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  final DbService _db = DbService();
  final AdaptiveEngine _engine = AdaptiveEngine();
  final AudioService _audio = AudioService();
  final SyncService _sync = SyncService();
  final LessonLoader _loader = LessonLoader();

  LessonPack? _currentPack;
  Lesson? _currentLesson;
  Question? _currentQuestion;
  int _questionIndex = 0;
  double _currentMastery = 0.5;
  bool _showHint = false;
  bool _answerSubmitted = false;
  String? _selectedAnswer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _sync.autoSyncIfNeeded();
  }

  Future<void> _loadContent() async {
    // Load lesson pack from assets (in production, this would be from downloaded SQLite data)
    _currentPack = await _loader.loadPackFromAssets('assets/lessons/fractions-kannada');

    if (_currentPack == null) {
      // Fallback to mock data if asset loading fails
      await _loadMockPack();
    }

    _currentLesson = _currentPack!.lessons.first;
    _currentMastery = await _db.getMastery(widget.student.id, _currentPack!.skills.first);
    _isLoading = false;
    setState(() {});

    _loadNextQuestion();
  }

  Future<void> _loadMockPack() async {
    // Mock data fallback - matches the asset content exactly
    _currentPack = LessonPack(
      packId: 'fractions-kannada-01',
      grade: 6,
      subject: 'math',
      language: 'kn',
      skills: ['fractions-addition-same-denom'],
      lessons: [
        Lesson(
          id: 'lesson-1',
          title: 'ಭಿನ್ನರಾಶಿಗಳು ಸೇರ್ಬಲೆ',
          narration: 'assets/lessons/fractions-kannada/narration-1.mp3',
          visual: 'assets/lessons/fractions-kannada/visual-1.svg',
          questions: ['q1', 'q2', 'q3'],
        ),
      ],
    );

    final questions = [
      Question(
        id: 'q1',
        skillId: 'fractions-addition-same-denom',
        difficulty: 'easy',
        questionText: '¼ + ¼ = ?',
        questionAudio: 'assets/lessons/fractions-kannada/q1.mp3',
        options: ['¼', '½', '¾', '1'],
        correctAnswer: '½',
        hintAudio: 'assets/lessons/fractions-kannada/hint-1.mp3',
        hintVisual: 'assets/lessons/fractions-kannada/hint-1.svg',
      ),
      Question(
        id: 'q2',
        skillId: 'fractions-addition-same-denom',
        difficulty: 'easy',
        questionText: '⅓ + ⅓ = ?',
        questionAudio: 'assets/lessons/fractions-kannada/q2.mp3',
        options: ['⅓', '⅔', '1', '½'],
        correctAnswer: '⅔',
        hintAudio: 'assets/lessons/fractions-kannada/hint-1.mp3',
        hintVisual: 'assets/lessons/fractions-kannada/hint-1.svg',
      ),
      Question(
        id: 'q3',
        skillId: 'fractions-addition-same-denom',
        difficulty: 'medium',
        questionText: '⅖ + ⅖ = ?',
        questionAudio: 'assets/lessons/fractions-kannada/q3.mp3',
        options: ['⅖', '⅗', '⅘', '1'],
        correctAnswer: '⅘',
        hintAudio: 'assets/lessons/fractions-kannada/hint-2.mp3',
        hintVisual: 'assets/lessons/fractions-kannada/hint-2.svg',
      ),
    ];

    await _db.insertQuestions(_currentPack!.packId, questions);
  }

  Future<void> _loadNextQuestion() async {
    if (_currentLesson == null || _questionIndex >= _currentLesson!.questionIds.length) {
      _showCompletionDialog();
      return;
    }

    final qId = _currentLesson!.questionIds[_questionIndex];
    _currentQuestion = await _db.getQuestion(qId);
    _answerSubmitted = false;
    _selectedAnswer = null;
    _showHint = false;
    setState(() {});
  }

  Future<void> _submitAnswer(String answer) async {
    if (_currentQuestion == null) return;

    final isCorrect = answer == _currentQuestion!.correctAnswer;
    _selectedAnswer = answer;
    _answerSubmitted = true;
    setState(() {});

    final result = await _engine.processAnswer(
      studentId: widget.student.id,
      skillId: _currentQuestion!.skillId,
      questionId: _currentQuestion!.id,
      isCorrect: isCorrect,
    );

    _currentMastery = result.newMastery;
    _showHint = result.showHint;

    // If wrong, show hint and play audio hint
    if (!isCorrect && result.showHint) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        await _audio.playAsset(_currentQuestion!.hintAudio);
      }
    }

    setState(() {});
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Complete!'),
        content: Text(
          'Mastery: ${(_currentMastery * 100).toInt()}%\n'
          '${_currentMastery >= 0.8 ? "Skill Mastered! 🎉" : "Keep practicing!"}',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Back to student select
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPack == null || _currentLesson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with student info and offline badge
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(widget.student.avatarPath),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_currentPack!.subject.toUpperCase()} • ${_currentPack!.language.toUpperCase()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const OfflineBadge(),
                  const SizedBox(width: 8),
                  Text(
                    '${(_currentMastery * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            // Lesson title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2E7D32),
              child: Text(
                _currentLesson!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Visual + Narration + Questions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Visual
                    if (_currentLesson!.visualAsset.endsWith('.svg'))
                      SvgPicture.asset(
                        _currentLesson!.visualAsset,
                        height: 200,
                        placeholderBuilder: (context) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else
                      Image.asset(
                        _currentLesson!.visualAsset,
                        height: 200,
                        fit: BoxFit.contain,
                      ),

                    const SizedBox(height: 24),

                    // Listen button for narration
                    ListenButton(
                      audioPath: _currentLesson!.narrationAudio,
                      label: 'Listen to Lesson',
                    ),

                    const SizedBox(height: 24),

                    // Question card
                    if (_currentQuestion != null)
                      QuestionCard(
                        question: _currentQuestion!,
                        selectedAnswer: _selectedAnswer,
                        showHint: _showHint,
                        answerSubmitted: _answerSubmitted,
                        correctAnswer: _answerSubmitted ? _currentQuestion!.correctAnswer : null,
                        onAnswer: _submitAnswer,
                        onListen: () => _audio.playAsset(_currentQuestion!.questionAudio),
                        onListenHint: _showHint
                            ? () => _audio.playAsset(_currentQuestion!.hintAudio)
                            : null,
                      ),
                  ],
                ),
              ),
            ),

            // Navigation
            if (_currentQuestion != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_questionIndex > 0)
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _questionIndex--;
                            _loadNextQuestion();
                          });
                        },
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(width: 80),
                    if (_answerSubmitted && _questionIndex < _currentLesson!.questionIds.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _questionIndex++;
                            _loadNextQuestion();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Next', style: TextStyle(color: Colors.white)),
                      )
                    else if (_answerSubmitted)
                      ElevatedButton(
                        onPressed: _showCompletionDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Finish', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
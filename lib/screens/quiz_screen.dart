import 'dart:async';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/quiz_service.dart';
import '../services/auth_service.dart';
import '../theme/color_tokens.dart';
import '../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  List<Word> _questions = [];
  int _currentIndex = 0;
  List<String> _options = [];
  int? _selectedIndex;
  bool _answered = false;
  bool _loading = true;
  int _correctCount = 0;
  int _wrongCount = 0;

  DateTime? _startTime;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _startTime = DateTime.now();
    try {
      _sessionId = await _quizService.startSession(user.id);
      final questions = await _quizService.buildQuiz(user.id);
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
        });
        if (questions.isNotEmpty) _generateOptions();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz hazırlanamadı: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    }
  }

  void _generateOptions() {
    final currentWord = _questions[_currentIndex];
    setState(() {
      _selectedIndex = null;
      _answered = false;
    });
    // Generate distractors
    _quizService.getDistractors(currentWord.turWordName).then((distractors) {
      final options = [currentWord.turWordName, ...distractors];
      options.shuffle();
      if (mounted) {
        setState(() => _options = options);
      }
    });
  }

  Future<void> _selectAnswer(int index) async {
    if (_answered) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    final currentWord = _questions[_currentIndex];
    final selected = _options[index];
    final isCorrect = selected == currentWord.turWordName;

    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    // Save answer
    try {
      await _quizService.submitAnswer(
          user.id, currentWord.wordId!, isCorrect);
      if (_sessionId != null) {
        await _quizService.saveAnswer(
          _sessionId!,
          user.id,
          currentWord.wordId!,
          selected,
          currentWord.turWordName,
          isCorrect,
        );
      }
    } catch (e) {
      debugPrint('Answer save error: $e');
    }

    setState(() {});
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final user = AuthService.currentUser;
    if (_sessionId != null && user != null) {
      final duration =
          DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;
      try {
        await _quizService.endSession(
          _sessionId!,
          _questions.length,
          _correctCount,
          duration,
        );
      } catch (e) {
        debugPrint('Session end error: $e');
      }
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizResult,
      arguments: {
        'total': _questions.length,
        'correct': _correctCount,
        'wrong': _wrongCount,
        'words': _questions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ZenBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: GlassAppBar(
            title: 'Quiz',
            leading: IconButton(
              icon: Icon(Icons.close, color: ColorTokens.textPrimary(context)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
                : _questions.isEmpty
                    ? _buildEmptyQuiz()
                    : _buildQuizContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyQuiz() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: ColorTokens.accent(context)),
              const SizedBox(height: 16),
              Text(
                'Bugün için tüm kelimeler tamam!',
                style: TextStyle(
                  color: ColorTokens.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Yeni kelimeler eklemek için kelime listenize göz atın.',
                style: TextStyle(color: ColorTokens.textSecondary(context), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ZenButton(
                onPressed: () => Navigator.pop(context),
                label: 'Ana Menü',
                color: ColorTokens.primary(context),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final currentWord = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soru ${_currentIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      color: ColorTokens.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '✓ $_correctCount  ✗ $_wrongCount',
                    style: TextStyle(
                      color: ColorTokens.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ZenProgressBar(
                progress: progress,
                color: ColorTokens.primary(context),
                height: 6,
              ),
            ],
          ),
        ),
        // Word card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ZenAnimations.staggeredEntrance(
            index: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Bu kelimenin Türkçe anlamı nedir?',
                    style: TextStyle(
                      color: ColorTokens.textSecondary(context),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    currentWord.engWordName,
                    style: TextStyle(
                      color: ColorTokens.primary(context),
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Options
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = _selectedIndex == index;
                final isCorrectOption =
                    _answered && option == currentWord.turWordName;

                Color borderColor = ColorTokens.border(context);
                Color bgColor = ColorTokens.surfaceElevated(context);

                if (_answered && isCorrectOption) {
                  bgColor = ColorTokens.success(context).withValues(alpha: 0.2);
                  borderColor = ColorTokens.success(context);
                } else if (_answered && isSelected && !isCorrectOption) {
                  bgColor = ColorTokens.error(context).withValues(alpha: 0.2);
                  borderColor = ColorTokens.error(context);
                } else if (isSelected) {
                  bgColor = ColorTokens.primary(context).withValues(alpha: 0.15);
                  borderColor = ColorTokens.primary(context);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ZenAnimations.staggeredEntrance(
                    index: index + 1,
                    child: GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: ColorTokens.textPrimary(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_answered && isCorrectOption)
                              Icon(Icons.check_circle_rounded, color: ColorTokens.success(context)),
                            if (_answered && isSelected && !isCorrectOption)
                              Icon(Icons.cancel_rounded, color: ColorTokens.error(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Next button
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(24),
            child: ZenAnimations.staggeredEntrance(
              index: _options.length + 1,
              child: ZenButton(
                onPressed: _nextQuestion,
                label: _currentIndex < _questions.length - 1 ? 'Sonraki Soru' : 'Sonuçları Gör',
                icon: Icons.arrow_forward_rounded,
                color: ColorTokens.primary(context),
                isFullWidth: true,
              ),
            ),
          ),
      ],
    );
  }
}

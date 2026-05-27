import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/wordle_service.dart';
import '../theme/color_tokens.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../widgets/common_widgets.dart';
import '../theme/animations.dart';
import '../constants/app_dimensions.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  final WordleService _wordleService = WordleService();

  String? _targetWord;
  String? _targetTurkish;
  List<List<LetterStatus>> _guesses = [];
  List<String> _guessWords = [];
  String _currentInput = '';
  bool _gameOver = false;
  bool _won = false;
  bool _loading = true;
  String _message = '';
  final int _maxAttempts = 6;

  final Map<String, LetterStatus> _keyboardStatus = {};

  static const _letters = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final wordData = await _wordleService.getWordleWord(user.id);
      if (wordData != null) {
        setState(() {
          _targetWord = wordData['name_en'] as String;
          _targetTurkish = wordData['name_tr'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _message = 'Henüz yeterli kelime öğrenmediniz. Önce quiz çözün!';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _message = 'Kelime yüklenemedi: $e';
      });
    }
  }

  void _onKeyPress(String letter) {
    if (_gameOver || _targetWord == null) return;
    if (_currentInput.length < 5) {
      setState(() {
        _currentInput += letter;
      });
    }
  }

  void _onBackspace() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  Future<void> _onEnter() async {
    if (_currentInput.length != 5 || _gameOver || _targetWord == null) return;

    final guess = _currentInput.toUpperCase();
    setState(() => _currentInput = '');
    _guessWords.add(guess);

    final validation = WordleService.validateGuess(guess, _targetWord!);
    _guesses.add(validation);

    for (int i = 0; i < 5; i++) {
      final letter = guess[i];
      final status = validation[i];
      final current = _keyboardStatus[letter];
      if (current == null || _priority(status) > _priority(current)) {
        _keyboardStatus[letter] = status;
      }
    }

    if (validation.every((s) => s == LetterStatus.correct)) {
      _gameOver = true;
      _won = true;
      _message = 'Tebrikler!';
    } else if (_guessWords.length >= _maxAttempts) {
      _gameOver = true;
      _won = false;
      _message = 'Kelime: $_targetWord -> $_targetTurkish';
    }
  }

  int _priority(LetterStatus s) {
    switch (s) {
      case LetterStatus.correct:
        return 2;
      case LetterStatus.present:
        return 1;
      case LetterStatus.absent:
        return 0;
    }
  }

  void _resetGame() {
    setState(() {
      _guesses = [];
      _guessWords = [];
      _currentInput = '';
      _gameOver = false;
      _won = false;
      _message = '';
      _keyboardStatus.clear();
    });
    _initGame();
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
            title: 'Wordle',
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: ColorTokens.primary(context)),
                onPressed: _resetGame,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
                : _targetWord == null
                    ? _buildNoWord()
                    : Column(
                        children: [
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _maxAttempts,
                                    (row) => _buildRow(row),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_message.isNotEmpty)
                            ZenAnimations.staggeredEntrance(
                              index: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Text(
                                    _message,
                                    style: TextStyle(
                                      color: _won ? ColorTokens.success(context) : ColorTokens.textPrimary(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ZenAnimations.staggeredEntrance(
                            index: 1,
                            child: _buildKeyboard(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoWord() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 64, color: ColorTokens.warning(context)),
              const SizedBox(height: 16),
              Text(
                'Wordle oynamak için önce quiz çözerek kelime öğrenin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorTokens.textPrimary(context),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ZenButton(
                onPressed: () => Navigator.pop(context),
                label: 'Geri Dön',
                color: ColorTokens.primary(context),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int row) {
    final hasGuess = row < _guessWords.length;
    final guess = hasGuess ? _guessWords[row] : '';
    final validation = hasGuess ? _guesses[row] : null;
    final isActive = row == _guessWords.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (col) {
          String letter;
          Color? bgColor;
          Color borderColor = ColorTokens.border(context);

          if (hasGuess) {
            letter = guess[col];
            final status = validation![col];
            switch (status) {
              case LetterStatus.correct:
                bgColor = const Color(0xFF538D4E);
                borderColor = const Color(0xFF538D4E);
                break;
              case LetterStatus.present:
                bgColor = const Color(0xFFB59F3B);
                borderColor = const Color(0xFFB59F3B);
                break;
              case LetterStatus.absent:
                bgColor = const Color(0xFF3A3A3C);
                borderColor = const Color(0xFF3A3A3C);
                break;
            }
          } else if (isActive && col < _currentInput.length) {
            letter = _currentInput[col];
            bgColor = ColorTokens.glassBg(context);
            borderColor = ColorTokens.textMuted(context);
          } else {
            letter = '';
            bgColor = ColorTokens.glassBg(context).withValues(alpha: 0.05);
            borderColor = ColorTokens.border(context);
          }

          return Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                if (isActive && letter.isNotEmpty)
                  BoxShadow(
                    color: ColorTokens.primary(context).withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: hasGuess || (isActive && letter.isNotEmpty) ? Colors.white : ColorTokens.textPrimary(context),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          ..._letters.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rowIndex == 2)
                    _keyboardButton('ENTER', _onEnter, flex: 3),
                  ...row.map((letter) {
                    final status = _keyboardStatus[letter];
                    Color bgColor;
                    switch (status) {
                      case LetterStatus.correct:
                        bgColor = const Color(0xFF538D4E);
                        break;
                      case LetterStatus.present:
                        bgColor = const Color(0xFFB59F3B);
                        break;
                      case LetterStatus.absent:
                        bgColor = const Color(0xFF3A3A3C);
                        break;
                      default:
                        bgColor = ColorTokens.surfaceElevated(context);
                    }
                    
                    return _keyboardButton(
                      letter,
                      () => _onKeyPress(letter),
                      bgColor: bgColor,
                    );
                  }),
                  if (rowIndex == 2)
                    _keyboardButton('\u232B', _onBackspace, flex: 3),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _keyboardButton(String label, VoidCallback onTap, {int flex = 2, Color? bgColor}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Material(
          color: bgColor ?? ColorTokens.surfaceElevated(context),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: label.length > 1 ? 12 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/animations.dart';
import '../screens/app_shell.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/game_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/word_detail_screen.dart';
import '../screens/word_list_screen.dart';
import '../screens/word_add_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/wordle_screen.dart';
import '../screens/word_chain_screen.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home'; // Now maps to AppShell
  static const game = '/game';
  static const progress = '/progress';
  static const settings = '/settings';
  static const wordDetail = '/word-detail';
  static const wordList = '/word-list';
  static const wordAdd = '/word-add';
  static const quiz = '/quiz';
  static const quizResult = '/quiz-result';
  static const wordle = '/wordle';
  static const wordChain = '/word-chain';

  static final routes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const AppShell(),
    game: (_) => const GameScreen(),
    progress: (_) => const ProgressScreen(),
    settings: (_) => const SettingsScreen(),
    wordList: (_) => const WordListScreen(),
    wordAdd: (_) => const WordAddScreen(),
    quiz: (_) => const QuizScreen(),
    quizResult: (_) => const QuizResultScreen(),
    wordle: (_) => const WordleScreen(),
    wordChain: (_) => const WordChainScreen(),
  };

  /// Navigate to word detail with a [Word] argument using zen transition.
  static void toWordDetail(BuildContext context, Word word) {
    Navigator.push(
      context,
      ZenAnimations.fadeSlideRoute(WordDetailScreen(word: word)),
    );
  }
}

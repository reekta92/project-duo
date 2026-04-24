import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const game = '/game';
  static const progress = '/progress';
  static const settings = '/settings';

  static final routes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const HomeScreen(),
    game: (_) => const GameScreen(),
    progress: (_) => const ProgressScreen(),
    settings: (_) => const SettingsScreen(),
  };
}

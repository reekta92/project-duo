import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/quiz_service.dart';
import '../services/settings_service.dart';
import '../routes/app_routes.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../constants/app_dimensions.dart';
import '../theme/animations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final QuizService _quizService = QuizService();
  final SettingsService _settingsService = SettingsService();

  bool _loading = true;
  int _dueCount = 0;
  int _newCount = 0;
  int _masteredCount = 0;
  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final settings = await _settingsService.loadSettings();
      final dueWords = await _quizService.getDueWords(user.id);
      final newWords =
          await _quizService.getNewWords(user.id, settings.dailyNewWordCount);
      final masteredCount = await _quizService.getMasteredCount(user.id);

      if (mounted) {
        setState(() {
          _dueCount = dueWords.length;
          _newCount = newWords.length;
          _masteredCount = masteredCount;
          _canStart = dueWords.isNotEmpty || newWords.isNotEmpty;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İstatistikler yüklenemedi: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Kelime Oyunu',
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadStats,
                color: ColorTokens.primary(context),
                backgroundColor: ColorTokens.glassBg(context, opacity: 0.9),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: AppDimensions.paddingPage,
                    right: AppDimensions.paddingPage,
                    top: AppDimensions.spacingLg,
                    bottom: AppDimensions.bottomNavHeight + AppDimensions.spacing2xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      ZenAnimations.staggeredEntrance(
                        index: 0,
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: 72,
                              color: ColorTokens.primary(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bugünkü Quiz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorTokens.textPrimary(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '6 tekrar prensibi ile kalıcı öğrenme',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorTokens.textSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stats cards
                      ZenAnimations.staggeredEntrance(
                        index: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                context,
                                'Tekrar',
                                '$_dueCount',
                                Icons.replay,
                                ColorTokens.warning(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                context,
                                'Yeni',
                                '$_newCount',
                                Icons.add_circle_outline,
                                ColorTokens.primary(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                context,
                                'Ustalaşan',
                                '$_masteredCount',
                                Icons.emoji_events,
                                ColorTokens.accent(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Start button
                      ZenAnimations.staggeredEntrance(
                        index: 2,
                        child: ZenButton(
                          onPressed: _canStart
                              ? () => Navigator.pushNamed(context, AppRoutes.quiz)
                              : null,
                          icon: Icons.play_arrow_rounded,
                          label: _canStart ? 'Quizi Başlat' : 'Tüm Kelimeler Tamamlandı!',
                          color: ColorTokens.primary(context),
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info card
                      ZenAnimations.staggeredEntrance(
                        index: 3,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nasıl Çalışır?',
                                style: TextStyle(
                                  color: ColorTokens.textPrimary(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _infoRow(context, '1', '6 kez üst üste doğru bil → öğrenme tamam'),
                              _infoRow(context, '2', '1 gün sonra ilk tekrar'),
                              _infoRow(context, '3', '1 hafta sonra ikinci tekrar'),
                              _infoRow(context, '4', '1 ay sonra üçüncü tekrar'),
                              _infoRow(context, '5', '3 ay sonra dördüncü tekrar'),
                              _infoRow(context, '6', '6 ay sonra beşinci tekrar'),
                              _infoRow(context, '🎯', '1 yıl sonra altıncı tekrar → USTALAŞTIN!'),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ColorTokens.warning(context).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: ColorTokens.warning(context), size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Herhangi bir adımda yanlış cevap verirsen öğrenme başa döner!',
                                        style: TextStyle(
                                          color: ColorTokens.warning(context),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: ColorTokens.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String step, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ColorTokens.primary(context).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: ColorTokens.primary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                desc,
                style: TextStyle(
                  color: ColorTokens.textSecondary(context),
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

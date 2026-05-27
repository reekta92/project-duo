import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/quiz_service.dart';
import '../services/report_service.dart';
import '../models/quiz_session.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../constants/app_dimensions.dart';
import '../theme/animations.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final QuizService _quizService = QuizService();
  final ReportService _reportService = ReportService();

  bool _loading = true;
  int _masteredCount = 0;
  int _inProgressCount = 0;
  double _accuracy = 0;
  List<QuizSession> _sessions = [];
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final mastered = await _quizService.getMasteredCount(user.id);
      final inProgress = await _quizService.getInProgressCount(user.id);
      final accuracy = await _quizService.getOverallAccuracy(user.id);
      final sessions = await _quizService.getSessionHistory(user.id);

      if (mounted) {
        setState(() {
          _masteredCount = mastered;
          _inProgressCount = inProgress;
          _accuracy = accuracy;
          _sessions = sessions;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenemedi: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _generatingPdf = true);
    try {
      await _reportService.generatePdfReport(user.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Gelişimim',
        automaticallyImplyLeading: false,
        actions: [
          _generatingPdf
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorTokens.primary(context),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.picture_as_pdf_rounded, color: ColorTokens.primary(context)),
                  tooltip: 'PDF Raporu',
                  onPressed: _exportPdf,
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
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
                      // Overall stats card
                      ZenAnimations.staggeredEntrance(
                        index: 0,
                        child: _buildOverallCard(context),
                      ),
                      const SizedBox(height: 16),

                      // Accuracy & progress
                      ZenAnimations.staggeredEntrance(
                        index: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMiniCard(
                                context,
                                'Başarı Oranı',
                                '%${_accuracy.round()}',
                                Icons.trending_up_rounded,
                                ColorTokens.accent(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniCard(
                                context,
                                'Ustalaşılan',
                                '$_masteredCount',
                                Icons.emoji_events_rounded,
                                ColorTokens.warning(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniCard(
                                context,
                                'Öğrenilen',
                                '$_inProgressCount',
                                Icons.school_rounded,
                                ColorTokens.primary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section header
                      ZenAnimations.staggeredEntrance(
                        index: 2,
                        child: SectionHeader(
                          title: 'Quiz Geçmişi',
                          subtitle: '${_sessions.length} oturum',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Session list
                      if (_sessions.isEmpty)
                        ZenAnimations.staggeredEntrance(
                          index: 3,
                          child: const EmptyState(
                            icon: Icons.history_rounded,
                            title: 'Henüz quiz geçmişi yok',
                            subtitle: 'Quiz çözmeye başladıkça geçmişiniz burada görünecek',
                          ),
                        )
                      else
                        ..._sessions.asMap().entries.map((entry) {
                          return ZenAnimations.staggeredEntrance(
                            index: 3 + entry.key,
                            child: _buildSessionCard(context, entry.value),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOverallCard(BuildContext context) {
    final totalWords = _masteredCount + _inProgressCount;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel Durum',
            style: TextStyle(
              color: ColorTokens.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCircle(context, 'Toplam', '$totalWords', ColorTokens.primary(context)),
              _statCircle(
                context,
                'Ustalaşılan',
                '$_masteredCount',
                ColorTokens.accent(context),
              ),
              _statCircle(
                context,
                'Öğrenilen',
                '$_inProgressCount',
                ColorTokens.warning(context),
              ),
            ],
          ),
          if (totalWords > 0) ...[
            const SizedBox(height: 24),
            ZenProgressBar(
              progress: _masteredCount / totalWords,
              color: ColorTokens.accent(context),
              height: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Ustalaşma: ${(_masteredCount / totalWords * 100).round()}%',
              style: TextStyle(
                color: ColorTokens.textSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCircle(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: ColorTokens.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
              fontSize: 22,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, QuizSession session) {
    final date = session.startedAt != null
        ? '${session.startedAt!.day}.${session.startedAt!.month}.${session.startedAt!.year}'
        : '-';
    final accuracy = session.accuracy.round();
    final color = accuracy >= 70 ? ColorTokens.success(context) : ColorTokens.warning(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Center(
                child: Text(
                  '%$accuracy',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: ColorTokens.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.totalQuestions} soru - ${session.correctAnswers} doğru ${session.wrongAnswers} yanlış',
                    style: TextStyle(
                      color: ColorTokens.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (session.durationSeconds != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorTokens.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(session.durationSeconds! / 60).round()}dk',
                  style: TextStyle(
                    color: ColorTokens.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

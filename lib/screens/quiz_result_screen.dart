import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/color_tokens.dart';
import '../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final total = (args?['total'] as int?) ?? 0;
    final correct = (args?['correct'] as int?) ?? 0;
    final wrong = (args?['wrong'] as int?) ?? 0;
    final words = (args?['words'] as List<Word>?) ?? [];

    final percentage = total > 0 ? (correct / total * 100).round() : 0;

    return Stack(
      children: [
        const ZenBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const GlassAppBar(
            title: 'Quiz Sonucu',
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Score circle
                  ZenAnimations.staggeredEntrance(
                    index: 0,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: percentage >= 70
                            ? ColorTokens.success(context).withValues(alpha: 0.15)
                            : percentage >= 40
                                ? ColorTokens.warning(context).withValues(alpha: 0.15)
                                : ColorTokens.error(context).withValues(alpha: 0.15),
                        border: Border.all(
                          color: percentage >= 70
                              ? ColorTokens.success(context)
                              : percentage >= 40
                                  ? ColorTokens.warning(context)
                                  : ColorTokens.error(context),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              color: percentage >= 70
                                  ? ColorTokens.success(context)
                                  : percentage >= 40
                                      ? ColorTokens.warning(context)
                                      : ColorTokens.error(context),
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Başarı',
                            style: TextStyle(color: ColorTokens.textSecondary(context), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats card
                  ZenAnimations.staggeredEntrance(
                    index: 1,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem(context, 'Toplam', '$total', ColorTokens.primary(context)),
                          _statItem(context, 'Doğru', '$correct', ColorTokens.success(context)),
                          _statItem(context, 'Yanlış', '$wrong', ColorTokens.error(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Word list
                  Expanded(
                    child: ZenAnimations.staggeredEntrance(
                      index: 2,
                      child: words.isEmpty
                          ? Center(child: Text('Sonuç bulunamadı', style: TextStyle(color: ColorTokens.textSecondary(context))))
                          : ListView.builder(
                              itemCount: words.length,
                              itemBuilder: (context, index) {
                                final word = words[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GlassCard(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: ColorTokens.success(context).withValues(alpha: 0.5),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                word.engWordName,
                                                style: TextStyle(
                                                  color: ColorTokens.textPrimary(context),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                word.turWordName,
                                                style: TextStyle(
                                                  color: ColorTokens.textSecondary(context),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  // Buttons
                  const SizedBox(height: 16),
                  ZenAnimations.staggeredEntrance(
                    index: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: ZenButton(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            ),
                            label: 'Ana Menü',
                            color: ColorTokens.surfaceElevated(context),
                            isFullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ZenButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.quiz,
                                (route) => false,
                              );
                            },
                            label: 'Tekrar Dene',
                            color: ColorTokens.primary(context),
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
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
}

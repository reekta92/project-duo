import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/word_service.dart';
import '../theme/color_tokens.dart';
import '../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../constants/app_dimensions.dart';
import '../theme/animations.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final WordService _wordService = WordService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Word> _words = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _loading = true);
    try {
      List<Word> words;
      if (_searchQuery.isNotEmpty) {
        words = await _wordService.searchWords(_searchQuery);
      } else {
        words = await _wordService.getWords(limit: 100);
      }
      if (mounted) setState(() => _words = words);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kelimeler yüklenemedi: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteWord(Word word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorTokens.glassBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kelimeyi Sil', style: TextStyle(color: ColorTokens.textPrimary(context))),
        content: Text('"${word.engWordName}" silinecek. Emin misiniz?', style: TextStyle(color: ColorTokens.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: TextStyle(color: ColorTokens.textSecondary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sil', style: TextStyle(color: ColorTokens.error(context))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _wordService.deleteWord(word.wordId!);
        await _loadWords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Kelime silindi ✓'),
              backgroundColor: ColorTokens.success(context),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silinemedi: $e'),
              backgroundColor: ColorTokens.error(context),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Kelimelerim',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: ColorTokens.primary(context)),
            onPressed: () async {
              await Navigator.pushNamed(context, '/word-add');
              _loadWords();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingPage,
                vertical: AppDimensions.spacingSm,
              ),
              child: ZenAnimations.staggeredEntrance(
                index: 0,
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: ColorTokens.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Kelime ara...',
                    prefixIcon: Icon(Icons.search, color: ColorTokens.textMuted(context)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: ColorTokens.textMuted(context)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                              _loadWords();
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _loadWords();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
                  : _words.isEmpty
                      ? const EmptyState(
                          icon: Icons.menu_book,
                          title: 'Henüz kelime yok',
                          subtitle: 'Sağ üstteki + butonuyla yeni kelime ekleyin',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadWords,
                          color: ColorTokens.primary(context),
                          backgroundColor: ColorTokens.glassBg(context, opacity: 0.9),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              left: AppDimensions.paddingPage,
                              right: AppDimensions.paddingPage,
                              bottom: AppDimensions.bottomNavHeight + AppDimensions.spacing2xl,
                            ),
                            itemCount: _words.length,
                            itemBuilder: (context, index) {
                              final word = _words[index];
                              return ZenAnimations.staggeredEntrance(
                                index: index % 10 + 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Dismissible(
                                    key: Key('word_${word.wordId}'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: ColorTokens.error(context).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusGlass),
                                      ),
                                      child: Icon(Icons.delete_outline, color: ColorTokens.error(context)),
                                    ),
                                    confirmDismiss: (_) async {
                                      return await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: ColorTokens.glassBg(context),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          title: Text('Kelimeyi Sil', style: TextStyle(color: ColorTokens.textPrimary(context))),
                                          content: Text('"${word.engWordName}" silinecek?', style: TextStyle(color: ColorTokens.textSecondary(context))),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: Text('İptal', style: TextStyle(color: ColorTokens.textSecondary(context))),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: Text('Sil', style: TextStyle(color: ColorTokens.error(context))),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (_) => _deleteWord(word),
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(4),
                                      onTap: () => AppRoutes.toWordDetail(context, word),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        leading: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: ColorTokens.primary(context).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.translate, color: ColorTokens.primary(context)),
                                        ),
                                        title: Text(
                                          word.engWordName,
                                          style: TextStyle(
                                            color: ColorTokens.textPrimary(context),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          word.turWordName,
                                          style: TextStyle(
                                            color: ColorTokens.textSecondary(context),
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: ColorTokens.border(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

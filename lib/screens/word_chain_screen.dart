import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/word_chain.dart';
import '../services/auth_service.dart';
import '../services/word_service.dart';
import '../services/word_chain_service.dart';
import '../services/llm_service.dart';
import '../services/settings_service.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final WordService _wordService = WordService();
  final WordChainService _chainService = WordChainService();
  final SettingsService _settingsService = SettingsService();
  late LLMService _llmService;

  List<Word> _allWords = [];
  final Set<int> _selectedWordIds = {};
  bool _loadingWords = true;
  bool _generating = false;

  // Result
  String? _story;
  String? _imageUrl;
  List<String> _usedWords = [];

  // History
  List<WordChain> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _llmService = LLMService();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _settingsService.getApiKey();
    _llmService.setApiKey(apiKey);
    await Future.wait([_loadWords(), _loadHistory()]);
  }

  Future<void> _loadWords() async {
    setState(() => _loadingWords = true);
    try {
      final words = await _wordService.getWords(limit: 200);
      if (mounted) setState(() => _allWords = words);
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
      if (mounted) setState(() => _loadingWords = false);
    }
  }

  Future<void> _loadHistory() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _loadingHistory = true);
    try {
      final chains = await _chainService.getWordChains(user.id);
      if (mounted) setState(() => _history = chains);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçmiş yüklenemedi: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _generate() async {
    if (_selectedWordIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('En az 3 kelime seçin'),
          backgroundColor: ColorTokens.warning(context),
        ),
      );
      return;
    }

    final words = _allWords
        .where((w) => _selectedWordIds.contains(w.wordId))
        .map((w) => w.engWordName)
        .toList();

    setState(() => _generating = true);

    try {
      final result = await _llmService.generateWordChain(words);
      if (mounted) {
        setState(() {
          _story = result['story'] as String;
          _imageUrl = result['image_url'] as String?;
          _usedWords = words;
          _generating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    }
  }

  Future<void> _saveChain() async {
    final user = AuthService.currentUser;
    if (user == null || _story == null) return;

    try {
      final chain = WordChain(
        userId: user.id,
        words: _usedWords,
        story: _story!,
        imageUrl: _imageUrl,
      );
      await _chainService.saveWordChain(chain);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hikaye kaydedildi ✓'),
            backgroundColor: ColorTokens.success(context),
          ),
        );
        // Reset
        setState(() {
          _story = null;
          _imageUrl = null;
          _usedWords = [];
          _selectedWordIds.clear();
        });
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydedilemedi: $e'),
            backgroundColor: ColorTokens.error(context),
          ),
        );
      }
    }
  }

  Future<void> _deleteChain(int id) async {
    try {
      await _chainService.deleteWordChain(id);
      _loadHistory();
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

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
            title: 'Word Chain',
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: ColorTokens.primary(context),
              labelColor: ColorTokens.primary(context),
              unselectedLabelColor: ColorTokens.textMuted(context),
              tabs: const [
                Tab(text: 'Oluştur', icon: Icon(Icons.edit_rounded)),
                Tab(text: 'Geçmiş', icon: Icon(Icons.history_rounded)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildCreateTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateTab() {
    if (_loadingWords) {
      return Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 140 + MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info
          ZenAnimations.staggeredEntrance(
            index: 0,
            child: Text(
              'En az 3 kelime seçin ve AI ile hikaye oluşturun',
              style: TextStyle(color: ColorTokens.textSecondary(context), fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          ZenAnimations.staggeredEntrance(
            index: 1,
            child: Text(
              '${_selectedWordIds.length} kelime seçildi',
              style: TextStyle(
                color: ColorTokens.primary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Word selection chips
          ZenAnimations.staggeredEntrance(
            index: 2,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allWords.map((word) {
                final selected = _selectedWordIds.contains(word.wordId);
                return FilterChip(
                  label: Text(
                    '${word.engWordName} (${word.turWordName})',
                    style: TextStyle(
                      color: selected ? Colors.white : ColorTokens.textPrimary(context),
                      fontSize: 13,
                    ),
                  ),
                  selected: selected,
                  selectedColor: ColorTokens.primary(context),
                  checkmarkColor: Colors.white,
                  backgroundColor: ColorTokens.surfaceElevated(context),
                  side: BorderSide(
                    color: selected ? ColorTokens.primary(context) : ColorTokens.border(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedWordIds.add(word.wordId!);
                      } else {
                        _selectedWordIds.remove(word.wordId);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Generate button
          ZenAnimations.staggeredEntrance(
            index: 3,
            child: ZenButton(
              onPressed: _generating || _selectedWordIds.length < 3 ? null : _generate,
              icon: Icons.auto_awesome_rounded,
              label: _generating ? 'Oluşturuluyor...' : 'Hikaye Oluştur',
              color: ColorTokens.primary(context),
              isFullWidth: true,
              isLoading: _generating,
            ),
          ),
          const SizedBox(height: 32),

          // Story result
          if (_story != null) ...[
            ZenAnimations.staggeredEntrance(
              index: 4,
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oluşturulan Hikaye',
                      style: TextStyle(
                        color: ColorTokens.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _story!,
                      style: TextStyle(
                        color: ColorTokens.textSecondary(context),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    if (_imageUrl != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _imageUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 250,
                            color: ColorTokens.border(context),
                            child: Icon(Icons.broken_image_rounded, color: ColorTokens.textMuted(context)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ZenAnimations.staggeredEntrance(
              index: 5,
              child: ZenButton(
                onPressed: _saveChain,
                icon: Icons.save_rounded,
                label: 'Kaydet',
                color: ColorTokens.primary(context),
                isFullWidth: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_loadingHistory) {
      return Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)));
    }

    if (_history.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'Henüz kayıtlı hikaye yok',
        subtitle: 'Oluştur sekmesinden ilk hikayenizi yapın',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 140 + MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 32,
      ),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final chain = _history[index];
        final date = chain.createdAt != null
            ? '${chain.createdAt!.day}.${chain.createdAt!.month}.${chain.createdAt!.year}'
            : '';

        return ZenAnimations.staggeredEntrance(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: Key('chain_${chain.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: ColorTokens.error(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorTokens.error(context).withValues(alpha: 0.5)),
                ),
                child: Icon(Icons.delete_outline_rounded, color: ColorTokens.error(context)),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ColorTokens.surfaceElevated(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Hikayeyi Sil', style: TextStyle(color: ColorTokens.textPrimary(context))),
                    content: Text('Bu hikaye silinecek. Emin misiniz?', style: TextStyle(color: ColorTokens.textSecondary(context))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('İptal', style: TextStyle(color: ColorTokens.textMuted(context))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Sil', style: TextStyle(color: ColorTokens.error(context), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) => _deleteChain(chain.id!),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chain.words.join(', '),
                            style: TextStyle(
                              color: ColorTokens.primary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: ColorTokens.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      chain.story,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorTokens.textSecondary(context),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (chain.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          chain.imageUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/word_service.dart';
import '../services/llm_service.dart';
import '../services/settings_service.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';

/// Story-2: Kelime detay ekranı - Örnek cümleler (WordSamples)
class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen>
    with SingleTickerProviderStateMixin {
  final WordService _wordService = WordService();
  final SettingsService _settingsService = SettingsService();
  late LLMService _llmService;

  List<WordSample> _samples = [];
  bool _loading = true;
  bool _generatingAI = false;
  final TextEditingController _sampleController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _llmService = LLMService();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _settingsService.getApiKey();
    _llmService.setApiKey(apiKey);
    await _loadSamples();
    _animController.forward();
  }

  Future<void> _loadSamples() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final samples = await _wordService.getSamples(widget.word.wordId!);
      if (mounted) setState(() => _samples = samples);
    } catch (e) {
      _showError('Cümleler yüklenemedi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addSample() async {
    final text = _sampleController.text.trim();
    if (text.isEmpty) return;

    try {
      final sample = WordSample(wordId: widget.word.wordId!, sample: text);
      await _wordService.addSample(sample);
      _sampleController.clear();
      await _loadSamples();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cümle eklendi ✓'),
            backgroundColor: ColorTokens.success(context),
          ),
        );
      }
    } catch (e) {
      _showError('Cümle eklenemedi: $e');
    }
  }

  Future<void> _generateWithAI() async {
    setState(() => _generatingAI = true);
    try {
      final sentences = await _llmService.generateExampleSentences(
        widget.word.engWordName,
        count: 3,
      );
      for (final s in sentences) {
        final sample = WordSample(wordId: widget.word.wordId!, sample: s);
        await _wordService.addSample(sample);
      }
      await _loadSamples();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sentences.length} AI cümlesi eklendi ✓'),
            backgroundColor: ColorTokens.secondary(context),
          ),
        );
      }
    } catch (e) {
      _showError('AI cümle oluşturulamadı: $e');
    } finally {
      if (mounted) setState(() => _generatingAI = false);
    }
  }

  Future<void> _deleteSample(WordSample sample) async {
    try {
      await _wordService.deleteSample(sample.wordSamplesId!);
      await _loadSamples();
    } catch (e) {
      _showError('Silinemedi: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ColorTokens.error(context)),
    );
  }

  @override
  void dispose() {
    _sampleController.dispose();
    _animController.dispose();
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
            title: widget.word.engWordName,
            actions: [
              if (_generatingAI)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorTokens.secondary(context),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.auto_awesome, color: ColorTokens.secondary(context)),
                  tooltip: 'AI ile cümle oluştur',
                  onPressed: _generateWithAI,
                ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildWordCard(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAddSampleSection(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: SectionHeader(
                        title: 'Örnek Cümleler',
                        subtitle: '${_samples.length} cümle',
                      ),
                    ),
                  ),
                  if (_loading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: LoadingShimmer(height: 70),
                        ),
                        childCount: 3,
                      ),
                    )
                  else if (_samples.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.format_quote_rounded,
                        title: 'Henüz örnek cümle yok',
                        subtitle: 'Manuel ekleyin veya AI ile otomatik oluşturun',
                        buttonLabel: 'AI ile Oluştur',
                        onButtonPressed: _generateWithAI,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sample = _samples[index];
                          return _buildSampleCard(sample, index);
                        },
                        childCount: _samples.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (widget.word.picture != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.word.picture!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _wordIconPlaceholder(),
              ),
            )
          else
            _wordIconPlaceholder(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.word.engWordName,
                  style: TextStyle(
                    color: ColorTokens.primary(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.word.turWordName,
                  style: TextStyle(
                    color: ColorTokens.textSecondary(context),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                StatusBadge(
                  label: '${_samples.length} cümle',
                  color: _samples.isEmpty ? ColorTokens.warning(context) : ColorTokens.success(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordIconPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: ColorTokens.primary(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.translate, color: ColorTokens.primary(context), size: 36),
    );
  }

  Widget _buildAddSampleSection() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Cümle Ekle',
            style: TextStyle(
              color: ColorTokens.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sampleController,
                  style: TextStyle(color: ColorTokens.textPrimary(context), fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '"${widget.word.engWordName}" kelimesini içeren bir cümle...',
                    hintStyle: TextStyle(
                      color: ColorTokens.textMuted(context),
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onSubmitted: (_) => _addSample(),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _addSample,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorTokens.accent(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCard(WordSample sample, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ZenAnimations.staggeredEntrance(
        index: index,
        child: Dismissible(
          key: Key('sample_${sample.wordSamplesId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: ColorTokens.error(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_outline, color: ColorTokens.error(context)),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: ColorTokens.glassBg(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Cümleyi Sil', style: TextStyle(color: ColorTokens.textPrimary(context))),
                content: Text('Bu cümle silinecek. Emin misiniz?', style: TextStyle(color: ColorTokens.textSecondary(context))),
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
          onDismissed: (_) => _deleteSample(sample),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColorTokens.primary(context).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: ColorTokens.primary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    sample.sample,
                    style: TextStyle(
                      color: ColorTokens.textPrimary(context),
                      fontSize: 15,
                      height: 1.5,
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
}

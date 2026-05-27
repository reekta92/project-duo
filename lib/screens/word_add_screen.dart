import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/word_service.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';
import '../constants/app_dimensions.dart';

class WordAddScreen extends StatefulWidget {
  final Word? word; // null = add, non-null = edit

  const WordAddScreen({super.key, this.word});

  @override
  State<WordAddScreen> createState() => _WordAddScreenState();
}

class _WordAddScreenState extends State<WordAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enCtrl = TextEditingController();
  final _trCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  final WordService _wordService = WordService();
  bool _saving = false;

  bool get _isEditing => widget.word != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _enCtrl.text = widget.word!.engWordName;
      _trCtrl.text = widget.word!.turWordName;
      _imgCtrl.text = widget.word!.picture ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final word = Word(
        wordId: widget.word?.wordId,
        engWordName: _enCtrl.text.trim(),
        turWordName: _trCtrl.text.trim(),
        picture: _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
      );

      if (_isEditing) {
        await _wordService.updateWord(word);
      } else {
        await _wordService.addWord(word);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Kelime güncellendi ✓' : 'Kelime eklendi ✓'),
          backgroundColor: ColorTokens.success(context),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: ColorTokens.error(context),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _enCtrl.dispose();
    _trCtrl.dispose();
    _imgCtrl.dispose();
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
            title: _isEditing ? 'Kelimeyi Düzenle' : 'Yeni Kelime Ekle',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              child: Form(
                key: _formKey,
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ZenAnimations.staggeredEntrance(
                        index: 0,
                        child: ZenTextField(
                          controller: _enCtrl,
                          labelText: 'İngilizce Kelime',
                          prefixIcon: Icons.language_rounded,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ZenAnimations.staggeredEntrance(
                        index: 1,
                        child: ZenTextField(
                          controller: _trCtrl,
                          labelText: 'Türkçe Anlamı',
                          prefixIcon: Icons.translate_rounded,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ZenAnimations.staggeredEntrance(
                        index: 2,
                        child: ZenTextField(
                          controller: _imgCtrl,
                          labelText: 'Görsel URL (opsiyonel)',
                          prefixIcon: Icons.image_outlined,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ZenAnimations.staggeredEntrance(
                        index: 3,
                        child: ZenButton(
                          onPressed: _saving ? null : _save,
                          label: _isEditing ? 'Güncelle' : 'Kaydet',
                          icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
                          color: ColorTokens.primary(context),
                          isFullWidth: true,
                          isLoading: _saving,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

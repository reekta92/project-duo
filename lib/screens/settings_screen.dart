import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/settings_service.dart';
import '../theme/color_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../constants/app_dimensions.dart';
import '../theme/animations.dart';

/// Story-4: Ayarlar Menüsü
/// Kullanıcı günlük yeni kelime sayısını ve diğer tercihlerini ayarlar
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = AppSettings();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
        _loading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    await _settingsService.saveSettings(_settings);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ayarlar kaydedildi ✓'),
          backgroundColor: ColorTokens.accent(context),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Ayarlar',
        automaticallyImplyLeading: false,
        actions: [
          if (_saving)
            Padding(
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
          else
            TextButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Kaydet'),
              style: TextButton.styleFrom(foregroundColor: ColorTokens.primary(context)),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: ColorTokens.primary(context)))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.paddingPage,
                  right: AppDimensions.paddingPage,
                  top: AppDimensions.spacingMd,
                  bottom: AppDimensions.bottomNavHeight + AppDimensions.spacing2xl,
                ),
                children: [
                  ZenAnimations.staggeredEntrance(
                    index: 0,
                    child: const SectionHeader(title: 'Çalışma Ayarları', icon: Icons.school_rounded),
                  ),
                  const SizedBox(height: 12),
                  ZenAnimations.staggeredEntrance(
                    index: 1,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SettingsRow(
                                  icon: Icons.add_circle_outline,
                                  title: 'Günlük Yeni Kelime Sayısı',
                                  subtitle: 'Her gün kaç yeni kelime öğrenmek istiyorsunuz?',
                                  trailing: Text(
                                    '${_settings.dailyNewWordCount}',
                                    style: TextStyle(
                                      color: ColorTokens.primary(context),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: ColorTokens.primary(context),
                                    inactiveTrackColor: ColorTokens.primary(context).withValues(alpha: 0.2),
                                    thumbColor: ColorTokens.primary(context),
                                    overlayColor: ColorTokens.primary(context).withValues(alpha: 0.1),
                                    valueIndicatorColor: ColorTokens.primary(context),
                                    valueIndicatorTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _settings.dailyNewWordCount.toDouble(),
                                    min: 5,
                                    max: 50,
                                    divisions: 9,
                                    label: '${_settings.dailyNewWordCount} kelime',
                                    onChanged: (val) {
                                      setState(() {
                                        _settings.dailyNewWordCount = val.round();
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _sliderLabel(context, '5 (Hafif)'),
                                    _sliderLabel(context, '25 (Orta)'),
                                    _sliderLabel(context, '50 (Yoğun)'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  ZenAnimations.staggeredEntrance(
                    index: 2,
                    child: const SectionHeader(title: 'Bildirim Ayarları', icon: Icons.notifications_rounded),
                  ),
                  const SizedBox(height: 12),
                  ZenAnimations.staggeredEntrance(
                    index: 3,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.notifications_outlined,
                            iconColor: ColorTokens.warning(context),
                            title: 'Bildirimler',
                            subtitle: 'Günlük hatırlatıcılar',
                            trailing: Switch(
                              value: _settings.notificationsEnabled,
                              onChanged: (val) {
                                setState(() => _settings.notificationsEnabled = val);
                              },
                              activeThumbColor: ColorTokens.warning(context),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: SettingsRow(
                              icon: Icons.access_time,
                              iconColor: ColorTokens.warning(context),
                              title: 'Bildirim Saati',
                              subtitle: _settings.notificationTime,
                              trailing: TextButton(
                                onPressed: _pickTime,
                                child: Text(
                                  'Değiştir',
                                  style: TextStyle(color: ColorTokens.primary(context)),
                                ),
                              ),
                            ),
                            crossFadeState: _settings.notificationsEnabled
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 250),
                          ),
                          SettingsRow(
                            icon: Icons.volume_up_outlined,
                            iconColor: ColorTokens.accent(context),
                            title: 'Ses Efektleri',
                            subtitle: 'Doğru/yanlış ses bildirimleri',
                            trailing: Switch(
                              value: _settings.soundEnabled,
                              onChanged: (val) {
                                setState(() => _settings.soundEnabled = val);
                              },
                              activeThumbColor: ColorTokens.accent(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),



                  ZenAnimations.staggeredEntrance(
                    index: 6,
                    child: const SectionHeader(title: 'Uygulama', icon: Icons.info_rounded),
                  ),
                  const SizedBox(height: 12),
                  ZenAnimations.staggeredEntrance(
                    index: 7,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.info_outline,
                            iconColor: ColorTokens.textMuted(context),
                            title: 'Versiyon',
                            trailing: Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: ColorTokens.textSecondary(context),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SettingsRow(
                            icon: Icons.school_outlined,
                            iconColor: ColorTokens.primary(context),
                            title: 'Tekrar Prensibi',
                            subtitle: '6 kez üst üste doğru → 1 gün → 1 hafta → ...',
                            trailing: Icon(
                              Icons.chevron_right,
                              color: ColorTokens.textMuted(context),
                            ),
                          ),
                          SettingsRow(
                            icon: Icons.delete_outline,
                            iconColor: ColorTokens.error(context),
                            title: 'Tüm Verileri Sıfırla',
                            subtitle: 'İlerleme ve ayarlar silinir',
                            trailing: TextButton(
                              onPressed: _confirmReset,
                              child: Text('Sıfırla', style: TextStyle(color: ColorTokens.error(context))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sliderLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: ColorTokens.textMuted(context), fontSize: 10),
    );
  }

  Future<void> _pickTime() async {
    final parts = _settings.notificationTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null && mounted) {
      setState(() {
        _settings.notificationTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorTokens.glassBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Verileri Sıfırla', style: TextStyle(color: ColorTokens.textPrimary(context))),
        content: Text(
            'Tüm ilerleme ve ayarlarınız silinecek. Bu işlem geri alınamaz.',
            style: TextStyle(color: ColorTokens.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: TextStyle(color: ColorTokens.textSecondary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sıfırla', style: TextStyle(color: ColorTokens.error(context))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _settingsService.saveSettings(AppSettings());
      await _loadSettings();
    }
  }
}

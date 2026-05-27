import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';

class SettingsService {
  static final _client = Supabase.instance.client;
  static const _table = 'app_settings';

  AppSettings? _cache;

  /// Load settings for the current signed-in user.
  Future<AppSettings> loadSettings() async {
    final user = _client.auth.currentUser;
    if (user == null) return AppSettings();

    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        _cache = AppSettings.fromJson(data);
      } else {
        // First launch — insert defaults
        _cache = AppSettings(userId: user.id);
        await _client.from(_table).upsert(_cache!.toJson());
      }
    } catch (_) {
      _cache ??= AppSettings(userId: user.id);
    }
    return _cache!;
  }

  /// Persist current settings.
  Future<void> saveSettings(AppSettings settings) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    settings.userId = user.id;
    await _client.from(_table).upsert(settings.toJson());
    _cache = settings;
  }

  /// Reset to defaults.
  Future<void> resetToDefaults() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final defaults = AppSettings(userId: user.id);
    await _client.from(_table).upsert(defaults.toJson());
    _cache = defaults;
  }

  /// Convenience: return just the API key.
  Future<String> getApiKey() async {
    final settings = _cache ?? await loadSettings();
    return settings.apiKey;
  }
}

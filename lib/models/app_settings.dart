class AppSettings {
  int dailyNewWordCount;
  bool notificationsEnabled;
  String notificationTime;
  bool soundEnabled;
  String apiKey;
  String userId;

  AppSettings({
    this.dailyNewWordCount = 15,
    this.notificationsEnabled = true,
    this.notificationTime = '09:00',
    this.soundEnabled = true,
    this.apiKey = '',
    this.userId = '',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyNewWordCount: (json['daily_word_count'] as int?) ?? 15,
      notificationsEnabled: (json['notifications_enabled'] as bool?) ?? true,
      notificationTime: (json['notification_time'] as String?) ?? '09:00',
      soundEnabled: (json['sound_enabled'] as bool?) ?? true,
      apiKey: (json['api_key'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'daily_word_count': dailyNewWordCount,
        'notifications_enabled': notificationsEnabled,
        'notification_time': notificationTime,
        'sound_enabled': soundEnabled,
        'api_key': apiKey,
        'user_id': userId,
      };
}

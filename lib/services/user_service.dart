import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserService {
  static final _client = Supabase.instance.client;

  static Future<UserProfile> getProfile(String userId) async {
    final data = await _client
        .from('Users')
        .select()
        .eq('userID', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  static Future<void> createProfile({
    required String userId,
    required String username,
    int dailyTarget = 10,
  }) {
    return _client.from('Users').insert({
      'userID': userId,
      'username': username,
      'daily_target': dailyTarget,
    });
  }

  static Future<void> updateProfile({
    required String userId,
    required String username,
    required int dailyTarget,
  }) {
    return _client
        .from('Users')
        .update({'username': username, 'daily_target': dailyTarget})
        .eq('userID', userId);
  }
}

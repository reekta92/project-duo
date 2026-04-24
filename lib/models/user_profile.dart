class UserProfile {
  final String id;
  final String username;
  final int dailyTarget;

  const UserProfile({
    required this.id,
    required this.username,
    required this.dailyTarget,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['userID'] as String,
      username: (json['username'] as String?) ?? '',
      dailyTarget: (json['daily_target'] as int?) ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'daily_target': dailyTarget,
  };
}

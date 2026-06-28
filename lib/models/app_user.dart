enum UserRole {
  host,
  participant,
}

class AppUser {
  const AppUser({
    this.uid,
    required this.name,
    required this.email,
    required this.role,

    // Quiz Features
    this.score = 0,
    this.streak = 0,
    this.xp = 0,
    this.level = 1,

    // Profile
    this.avatar,
    this.isOnline = true,
  });

  /// UID dari Supabase Auth
  final String? uid;

  // Basic Info
  final String name;
  final String email;
  final UserRole role;

  // Quiz Statistics
  final int score;
  final int streak;
  final int xp;
  final int level;

  // Profile
  final String? avatar;
  final bool isOnline;

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    int? score,
    int? streak,
    int? xp,
    int? level,
    String? avatar,
    bool? isOnline,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  bool get isHost => role == UserRole.host;

  bool get isParticipant => role == UserRole.participant;

  String get rankTitle {
    if (level >= 10) return 'Quiz Master';
    if (level >= 7) return 'Quiz Expert';
    if (level >= 4) return 'Quiz Pro';
    return 'Beginner';
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, email: $email, level: $level)';
  }
}

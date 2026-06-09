enum UserRole {
  host,
  participant,
}

class AppUser {
  const AppUser({
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

  // Basic Info
  final String name;
  final String email;
  final UserRole role;

  // Quiz Statistics
  final int score;
  final int streak;
  final int xp;
  final int level;

  // Profile & Lobby
  final String? avatar;
  final bool isOnline;

  AppUser copyWith({
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
    return 'AppUser(name: $name, score: $score, level: $level)';
  }
}
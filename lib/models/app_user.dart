enum UserRole { host, participant }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({
    this.id = '',
    required this.name,
    required this.email,
    required this.role,
  });
}

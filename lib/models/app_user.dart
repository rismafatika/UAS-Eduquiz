enum UserRole { host, participant }

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final UserRole role;
}

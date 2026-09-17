class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
  });
}
class StaffProfile {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool isOnline;

  const StaffProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.isOnline,
  });
}
import '../../domain/entities/staff_profile.dart';

class StaffProfileModel extends StaffProfile {
  const StaffProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.profileImage,
    super.latitude,
    super.longitude,
    super.locationName,
    required super.isOnline,
  });

  factory StaffProfileModel.fromMap(Map<String, dynamic> map) {
    return StaffProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImage: map['profileImage'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationName: map['locationName'],
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isOnline': isOnline,
    };
  }
}
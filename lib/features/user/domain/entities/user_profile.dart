import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phone,
        profileImage,
        latitude,
        longitude,
        locationName,
      ];
}
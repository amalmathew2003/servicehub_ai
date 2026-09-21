import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// ============================================================
// BOOKING IMPORTS
// ============================================================

import 'package:service_hub_ai/features/booking/data/datasources/booking_datasource.dart';
import 'package:service_hub_ai/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:service_hub_ai/features/booking/domain/repositories/booking_repository.dart';
import 'package:service_hub_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:service_hub_ai/features/booking/domain/usecases/get_staff_bookings.dart';
import 'package:service_hub_ai/features/booking/domain/usecases/update_booking_status.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_bloc.dart';

// ============================================================
// AUTH IMPORTS
// ============================================================

import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/google_login.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// ============================================================
// STAFF SERVICE IMPORTS
// ============================================================

import '../../features/staff/data/datasources/staff_service_datasource.dart';
import '../../features/staff/data/repositories/staff_service_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_service_repository.dart';
import '../../features/staff/domain/usecases/add_staff_service.dart';
import '../../features/staff/domain/usecases/get_staff_services.dart';
import '../../features/staff/presentation/bloc/staff_service_bloc.dart';

// ============================================================
// STAFF PROFILE IMPORTS
// ============================================================

import '../../features/staff/data/datasources/staff_profile_datasource.dart';
import '../../features/staff/data/repositories/staff_profile_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_profile_repository.dart';
import '../../features/staff/domain/usecases/get_staff_profile.dart';
import '../../features/staff/domain/usecases/update_staff_profile.dart';
import '../../features/staff/presentation/bloc/staff_profile_bloc.dart';

// ============================================================
// LOCATION IMPORTS
// ============================================================

import '../../features/location/data/location_service.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location.dart';
import '../../features/location/domain/usecases/get_location_name.dart';
import '../../features/location/domain/usecases/get_location_stream.dart';

// ============================================================
// USER PROFILE IMPORTS
// ============================================================

import '../../features/user/data/datasources/user_profile_datasource.dart';
import '../../features/user/data/repositories/user_profile_repository_impl.dart';
import '../../features/user/domain/repositories/user_profile_repository.dart';
import '../../features/user/domain/usecases/get_user_profile.dart';
import '../../features/user/domain/usecases/update_user_profile.dart';
import '../../features/user/presentation/bloc/user_profile_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ============================================================
  // FIREBASE
  // ============================================================

  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ============================================================
  // AUTH FEATURE
  // ============================================================

  // -------------------- Datasource --------------------

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasource(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: sl<AuthDatasource>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<RegisterUser>(
    () => RegisterUser(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<LoginUser>(
    () => LoginUser(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<GoogleLogin>(
    () => GoogleLogin(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<LogoutUser>(
    () => LogoutUser(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(
      sl<AuthRepository>(),
    ),
  );

  // -------------------- Bloc --------------------

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUser: sl<RegisterUser>(),
      loginUser: sl<LoginUser>(),
      googleLogin: sl<GoogleLogin>(),
      logoutUser: sl<LogoutUser>(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );

  // ============================================================
  // STAFF SERVICE FEATURE
  // ============================================================

  // -------------------- Datasource --------------------

  sl.registerLazySingleton<StaffServiceDatasource>(
    () => StaffServiceDatasource(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<StaffServiceRepository>(
    () => StaffServiceRepositoryImpl(
      datasource: sl<StaffServiceDatasource>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<AddStaffService>(
    () => AddStaffService(
      sl<StaffServiceRepository>(),
    ),
  );

  sl.registerLazySingleton<GetStaffServices>(
    () => GetStaffServices(
      sl<StaffServiceRepository>(),
    ),
  );

  // -------------------- Bloc --------------------

  sl.registerFactory<StaffServiceBloc>(
    () => StaffServiceBloc(
      addStaffService: sl<AddStaffService>(),
      getStaffServices: sl<GetStaffServices>(),
    ),
  );

  // ============================================================
  // STAFF PROFILE FEATURE
  // ============================================================

  // -------------------- Datasource --------------------

  sl.registerLazySingleton<StaffProfileDatasource>(
    () => StaffProfileDatasource(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<StaffProfileRepository>(
    () => StaffProfileRepositoryImpl(
      datasource: sl<StaffProfileDatasource>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<GetStaffProfile>(
    () => GetStaffProfile(
      sl<StaffProfileRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateStaffProfile>(
    () => UpdateStaffProfile(
      sl<StaffProfileRepository>(),
    ),
  );

  // -------------------- Bloc --------------------

  sl.registerFactory<StaffProfileBloc>(
    () => StaffProfileBloc(
      getStaffProfile: sl<GetStaffProfile>(),
      updateStaffProfile: sl<UpdateStaffProfile>(),
      getCurrentLocation: sl<GetCurrentLocation>(),
      getLocationName: sl<GetLocationName>(),
      getLocationStream: sl<GetLocationStream>(),
    ),
  );

  // ============================================================
  // LOCATION FEATURE
  // ============================================================

  // -------------------- Location Service --------------------

  sl.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      locationService: sl<LocationService>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(
      repository: sl<LocationRepository>(),
    ),
  );

  sl.registerLazySingleton<GetLocationName>(
    () => GetLocationName(
      repository: sl<LocationRepository>(),
    ),
  );

  sl.registerLazySingleton<GetLocationStream>(
    () => GetLocationStream(
      repository: sl<LocationRepository>(),
    ),
  );

  // ============================================================
  // BOOKING FEATURE
  // ============================================================

  // -------------------- Datasource --------------------

  sl.registerLazySingleton<BookingDatasource>(
    () => BookingDatasource(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      datasource: sl<BookingDatasource>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<CreateBooking>(
    () => CreateBooking(
      sl<BookingRepository>(),
    ),
  );

  sl.registerLazySingleton<GetStaffBookings>(
    () => GetStaffBookings(
      sl<BookingRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateBookingStatus>(
    () => UpdateBookingStatus(
      sl<BookingRepository>(),
    ),
  );

  // -------------------- Bloc --------------------

  sl.registerFactory<BookingBloc>(
    () => BookingBloc(
      createBooking: sl<CreateBooking>(),
      getStaffBookings: sl<GetStaffBookings>(),
      updateBookingStatus: sl<UpdateBookingStatus>(),
    ),
  );

  // ============================================================
  // USER PROFILE FEATURE
  // ============================================================

  // -------------------- Datasource --------------------

  sl.registerLazySingleton<UserProfileDatasource>(
    () => UserProfileDatasource(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // -------------------- Repository --------------------

  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      datasource: sl<UserProfileDatasource>(),
    ),
  );

  // -------------------- UseCases --------------------

  sl.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(
      sl<UserProfileRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateUserProfile>(
    () => UpdateUserProfile(
      sl<UserProfileRepository>(),
    ),
  );

  // -------------------- Bloc --------------------

sl.registerFactory<UserProfileBloc>(
  () => UserProfileBloc(
    getUserProfile: sl<GetUserProfile>(),
    updateUserProfile: sl<UpdateUserProfile>(),
    getCurrentLocation: sl<GetCurrentLocation>(),
    getLocationName: sl<GetLocationName>(),
  ),
);
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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

final sl = GetIt.instance;

void setupDependencies() {
  // ============================================================
  // Firebase
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
    ),
  );
}
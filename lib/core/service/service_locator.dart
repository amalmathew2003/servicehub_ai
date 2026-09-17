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

final sl = GetIt.instance;

void setupDependencies() {
  // Firebase

  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Datasource

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasource(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: sl<AuthDatasource>(),
    ),
  );

  // UseCases

  sl.registerLazySingleton<RegisterUser>(
    () => RegisterUser(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginUser>(
    () => LoginUser(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GoogleLogin>(
    () => GoogleLogin(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogoutUser>(
    () => LogoutUser(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );

  // Bloc

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUser: sl<RegisterUser>(),
      loginUser: sl<LoginUser>(),
      googleLogin: sl<GoogleLogin>(),
      logoutUser: sl<LogoutUser>(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );
}
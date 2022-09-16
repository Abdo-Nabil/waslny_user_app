import 'package:waslny_user/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:waslny_user/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:waslny_user/features/authentication/data/repositories/auth_repo_impl.dart';
import 'package:waslny_user/features/authentication/domain/repositories/auth_repo.dart';
import 'package:waslny_user/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/login_or_resend_sms_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/get_user_data_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/set_token_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/verify_sms_code_use_case.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/general_cubit/general_cubit.dart';
import 'package:waslny_user/features/home_screen/services/home_local_data.dart';
import 'package:waslny_user/features/home_screen/services/home_remote_data.dart';
import 'package:waslny_user/features/home_screen/services/home_repo.dart';
import 'package:waslny_user/features/localization/data/datasources/localization_local_data_source.dart';
import 'package:waslny_user/features/localization/domain/repositories/localization_repository.dart';
import 'package:waslny_user/features/localization/domain/usecases/get_locale_use_case.dart';
import 'package:waslny_user/features/theme/presentation/cubits/theme_cubit.dart';

import 'core/network/network_info.dart';
import 'features/authentication/domain/usecases/create_user_use_case.dart';
import 'features/home_screen/cubits/home_screen_cubit.dart';
import 'features/localization/data/repositories/localization_repository_impl.dart';
import 'features/localization/domain/usecases/set_locale_use_case.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/localization/domain/usecases/set_to_system_locale.dart';
import 'features/localization/presentation/cubits/localization_cubit.dart';
import 'features/theme/data/datasources/theme_local_data_source.dart';
import 'features/theme/data/repositories/theme_repository_impl.dart';
import 'features/theme/domain/repositories/theme_repository.dart';
import 'features/theme/domain/usecases/get_theme_use_case.dart';
import 'features/theme/domain/usecases/set_theme_use_case.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await initLocalization();
  await initTheme();
  await initGeneralCubit();
  await initializeAuth();
  await initHomeScreen();
}

Future<void> initLocalization() async {
//
//---------------------* Localization *-------------------------------
//! Features - Localization

//! Bloc

  sl.registerFactory(() => LocalizationCubit(
        getLocaleUseCase: sl(),
        setLocaleUseCase: sl(),
        setToSystemLocaleUseCase: sl(),
      ));

//! Use Cases

  sl.registerLazySingleton(
      () => GetLocaleUseCase(localizationRepository: sl()));
  sl.registerLazySingleton(
      () => SetLocaleUseCase(localizationRepository: sl()));
  sl.registerLazySingleton(
      () => SetToSystemLocaleUseCase(localizationRepository: sl()));

//! Repository

  sl.registerLazySingleton<LocalizationRepository>(
    () => LocalizationRepositoryImpl(localizationLocalDataSource: sl()),
  );

//! Data Sources

  sl.registerLazySingleton<LocalizationLocalDataSource>(
      () => LocalizationLocalDataSourceImpl(sharedPreferences: sl()));

//! Core

//! External
//
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
}

Future<void> initTheme() async {
//
//---------------------* Theme *-------------------------------
//! Features - Theme

//! Bloc

  sl.registerFactory(
      () => ThemeCubit(getThemeUseCase: sl(), setThemeUseCase: sl()));

//! Use Cases

  sl.registerLazySingleton(() => GetThemeUseCase(themeRepository: sl()));
  sl.registerLazySingleton(() => SetThemeUseCase(themeRepository: sl()));

//! Repository

  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(themeLocalDataSource: sl()),
  );

//! Data Sources

  sl.registerLazySingleton<ThemeLocalDataSource>(
      () => ThemeLocalDataSourceImpl(sharedPreferences: sl()));

//! Core

//! External

  //****** These lines have been implemented in Localization Feature ******
  // final sharedPreferences = await SharedPreferences.getInstance();
  // sl.registerLazySingleton(() => sharedPreferences);
}

Future<void> initGeneralCubit() async {
//
//---------------------* initGeneralCubit *-------------------------------

//! Bloc

  sl.registerFactory(() => GeneralCubit(sharedPreferences: sl()));

//! Use Cases

//! Repository

//! Data Sources

//! Core

//! External
}

Future<void> initializeAuth() async {
//
//---------------------* Authentication *-------------------------------

//! Features - Authentication

//! Bloc

  sl.registerFactory(() => AuthCubit(
        createUserUseCase: sl(),
        getUserDataUseCase: sl(),
        loginOrResendSmsUseCase: sl(),
        verifySmsCodeUseCase: sl(),
        getTokenUseCase: sl(),
        setTokenUseCase: sl(),
      ));

//! Use Cases
  sl.registerLazySingleton(() => CreateUserUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => GetUserDataUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => LoginOrResendSmsUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => VerifySmsCodeUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => SetTokenUseCase(authRepo: sl()));

//! Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(
        authLocalDataSource: sl(),
        authRemoteDataSource: sl(),
        networkInfo: sl(),
      ));

//! Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()));

//! Core

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

//! External

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}

Future<void> initHomeScreen() async {
  sl.registerFactory(() => HomeScreenCubit(sl()));

  sl.registerLazySingleton<HomeRemoteData>(
      () => HomeRemoteData(networkInfo: sl(), client: sl()));
  sl.registerLazySingleton<HomeLocalData>(() => HomeLocalData());
  sl.registerLazySingleton<HomeRepo>(() => HomeRepo(sl(), sl()));
}

//-----------------------------------------------------------------
//
// //! Features - posts
//
// // Bloc
//
//   sl.registerFactory(() => PostsBloc(getAllPosts: sl()));
//   sl.registerFactory(() => AddDeleteUpdatePostBloc(
//       addPost: sl(), updatePost: sl(), deletePost: sl()));
//
// // Usecases
//
//   sl.registerLazySingleton(() => GetAllPostsUsecase(sl()));
//   sl.registerLazySingleton(() => AddPostUsecase(sl()));
//   sl.registerLazySingleton(() => DeletePostUsecase(sl()));
//   sl.registerLazySingleton(() => UpdatePostUsecase(sl()));
//
// // Repository
//
//   sl.registerLazySingleton<PostsRepository>(() => PostsRepositoryImpl(
//       remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()));
//
// // Datasources
//
//   sl.registerLazySingleton<PostRemoteDataSource>(
//       () => PostRemoteDataSourceImpl(client: sl()));
//   sl.registerLazySingleton<PostLocalDataSource>(
//       () => PostLocalDataSourceImpl(sharedPreferences: sl()));
//
// //! Core
//
//   sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
//
// //! External
//
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
//   sl.registerLazySingleton(() => http.Client());
//   sl.registerLazySingleton(() => InternetConnectionChecker());

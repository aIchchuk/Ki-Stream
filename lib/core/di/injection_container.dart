import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/music/data/models/song_model.dart';
import '../../features/music/data/repositories/song_repository_impl.dart';
import '../../features/music/domain/repositories/song_repository.dart';
import '../../features/music/presentation/bloc/song_bloc.dart';
import '../../features/music/presentation/bloc/player_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  await Hive.initFlutter();
  debugPrint('Hive initialized.');

  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  final songBox = await Hive.openBox<SongModel>('songs');
  final userBox = await Hive.openBox<UserModel>('user');
  final usersDbBox = await Hive.openBox('users_db');

  debugPrint(
    'Hive Boxes opened. Songs: ${songBox.length}, DB Users: ${usersDbBox.length}',
  );

  // External
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => songBox);
  sl.registerLazySingleton(() => userBox);

  // Features - Music
  sl.registerFactory(() => SongBloc(sl()));
  sl.registerFactory(() => PlayerBloc());
  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(sl()));

  // Features - Auth
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), usersDbBox),
  );
}

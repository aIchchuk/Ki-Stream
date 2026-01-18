import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/music/presentation/bloc/song_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/music/data/models/song_model.dart';
import 'features/music/presentation/bloc/player_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // DEBUG: Print all Hive data using Service Locator
  final songBox = di.sl<Box<SongModel>>();
  final userBox = di.sl<Box<UserModel>>();
  final usersDbBox = di
      .sl<AuthRepository>()
      .getAllUsers(); // Use repository method

  if (songBox.isEmpty) debugPrint('No songs found in Hive.');

  final currentUser = userBox.get('currentUser');
  if (currentUser != null) {
    debugPrint('Session found for: ${currentUser.email}');
  } else {
    debugPrint('No active session found.');
  }

  debugPrint('Total Registered Users: ${(await usersDbBox).length}');
  debugPrint(
    'Total Manual Songs: ${songBox.values.where((s) => s.isManual == true).length}',
  );

  runApp(const KiStreamApp());
}

class KiStreamApp extends StatelessWidget {
  const KiStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SongBloc>()),
        BlocProvider(create: (_) => di.sl<PlayerBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'KiStream',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}

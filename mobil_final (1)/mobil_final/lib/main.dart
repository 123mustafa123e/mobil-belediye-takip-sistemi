import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_routes.dart';
import 'core/network/app_api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/abonelik/bloc/abonelik_cubit.dart';
import 'features/ariza/bloc/ariza_cubit.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'shared/repositories/ariza_repository.dart';
import 'shared/repositories/auth_repository.dart';
import 'shared/services/session_service.dart';
import 'shared/services/abonelik_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dqbaeervsoysviixryrm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxYmFlZXJ2c295c3ZpaXhyeXJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA0MjMxNzgsImV4cCI6MjA5NTk5OTE3OH0.YvsFuPiYBBFxML0XyFW8sMFD2gQ7y2GSFeP7rQU_S2c',
  );

  final prefs = await SharedPreferences.getInstance();
  final sessionService = SessionService(prefs);
  final abonelikService = AbonelikService(prefs);
  final apiClient = AppApiClient();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            AuthRepository(
              apiClient: apiClient,
              sessionService: sessionService,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => ArizaCubit(
            ArizaRepository(
              apiClient: apiClient,
              sessionService: sessionService,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => AbonelikCubit(abonelikService)..loadAbonelikler(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belediye Arıza Takip Sistemi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

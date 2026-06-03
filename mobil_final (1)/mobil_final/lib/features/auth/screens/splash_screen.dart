import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    final authCubit = context.read<AuthCubit>();
    await authCubit.loadSession();

    if (!mounted) {
      return;
    }

    if (authCubit.state.isAuthenticated) {
      final target = authCubit.state.role == AppConstants.tipKurum
          ? AppRoutes.kurumDashboard
          : AppRoutes.userDashboard;
      Navigator.pushReplacementNamed(context, target);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Belediye Arıza Takip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

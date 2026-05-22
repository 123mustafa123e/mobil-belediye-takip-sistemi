import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 saniye bekledikten sonra giriş ekranına yönlendiriyoruz
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
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
            Text('Belediye Arıza Takip', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

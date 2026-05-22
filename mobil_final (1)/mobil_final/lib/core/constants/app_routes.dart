import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/user_dashboard_screen.dart';
import '../../features/dashboard/screens/kurum_dashboard_screen.dart';
import '../../features/ariza/screens/ariza_bildir_screen.dart';
import '../../features/ariza/screens/ariza_detay_screen.dart';
import '../../features/ariza/screens/ariza_listesi_screen.dart';
import '../../features/takip/screens/takip_screen.dart';
import '../../features/kurum/screens/kurum_sikayet_listesi_screen.dart';
import '../../features/kurum/screens/kurum_sikayet_detay_screen.dart';
import '../../features/profil/screens/profil_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String userDashboard = '/user/dashboard';
  static const String kurumDashboard = '/kurum/dashboard';
  static const String arizaBildir = '/ariza/bildir';
  static const String arizaDetay = '/ariza/detay';
  static const String arizaListesi = '/ariza/listesi';
  static const String takip = '/takip';
  static const String kurumSikayetListesi = '/kurum/sikayetler';
  static const String kurumSikayetDetay = '/kurum/sikayet/detay';
  static const String profil = '/profil';
  static const String mapScreen = '/map';
  static const String aiAssistant = '/ai_assistant';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      case login:
        return _slideRoute(const LoginScreen());
      case register:
        return _slideRoute(const RegisterScreen());
      case userDashboard:
        return _fadeRoute(const UserDashboardScreen());
      case kurumDashboard:
        return _fadeRoute(const KurumDashboardScreen());
      case arizaBildir:
        return _slideRoute(const ArizaBildirScreen());
      case arizaDetay:
        final args = settings.arguments as Map<String, dynamic>?;
        final arizaId = args?['arizaId'] as String? ?? '';
        return _slideRoute(ArizaDetayScreen(arizaId: arizaId));
      case arizaListesi:
        return _slideRoute(const ArizaListesiScreen());
      case takip:
        return _slideRoute(const TakipScreen());
      case kurumSikayetListesi:
        return _slideRoute(const KurumSikayetListesiScreen());
      case kurumSikayetDetay:
        final args = settings.arguments as Map<String, dynamic>?;
        final sikayetId = args?['sikayetId'] as String? ?? '';
        return _slideRoute(KurumSikayetDetayScreen(arizaId: sikayetId));
      case profil:
        return _slideRoute(const ProfilScreen());
      case mapScreen:
        return _slideRoute(const MapScreen());
      case aiAssistant:
        return _slideRoute(const AiAssistantScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Hata')),
            body: Center(child: Text('Route bulunamadı: ${settings.name}')),
          ),
        );
    }
  }

  // FadeTransition Animasyonlu Geçiş
  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // SlideTransition Animasyonlu Geçiş
  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

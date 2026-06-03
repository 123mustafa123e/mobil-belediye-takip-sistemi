import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _vatandasFormKey = GlobalKey<FormState>();
  final _kurumFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kurumKoduController = TextEditingController();
  final _kurumPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _kurumKoduController.dispose();
    _kurumPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loginVatandas() async {
    if (!_vatandasFormKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: AppConstants.tipVatandas,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.userDashboard);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _loginKurum() async {
    if (!_kurumFormKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthCubit>().login(
        email: _kurumKoduController.text.trim(),
        password: _kurumPasswordController.text.trim(),
        role: AppConstants.tipKurum,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.kurumDashboard);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Giriş Yap',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Vatandaş', icon: Icon(Icons.person)),
              Tab(text: 'Kurum', icon: Icon(Icons.business)),
            ],
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      _buildVatandasGiris(context),
                      _buildKurumGiris(context),
                    ],
                  ),
                  if (state.isLoading)
                    const ColoredBox(
                      color: Color.fromRGBO(255, 255, 255, 0.6),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVatandasGiris(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _vatandasFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.location_city, size: 80, color: AppColors.primary),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'E-posta boş bırakılamaz';
                }
                if (!value.contains('@')) {
                  return 'Geçerli bir e-posta giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre boş bırakılamaz';
                }
                if (value.length < 6) {
                  return 'Şifre en az 6 karakter olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loginVatandas,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
              child: const Text(
                'Hesabınız yok mu? Kayıt Ol',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKurumGiris(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _kurumFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _kurumKoduController,
              decoration: InputDecoration(
                labelText: 'Kurum E-posta',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kurum e-postası boş bırakılamaz';
                }
                if (!value.contains('@')) {
                  return 'Geçerli bir e-posta giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kurumPasswordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre boş bırakılamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loginKurum,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

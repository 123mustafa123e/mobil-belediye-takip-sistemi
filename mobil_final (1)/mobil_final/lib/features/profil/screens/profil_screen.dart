import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../auth/bloc/auth_cubit.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          appBar: AppBar(title: const Text('Profilim')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user == null ? 'Kullanıcı' : '${user.ad} ${user.soyad}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? 'E-posta yok',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Kişisel Bilgilerimi Düzenle'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Bildirim Ayarları'),
                trailing: Switch(
                  value: user?.bildirimAktif ?? true,
                  onChanged: (_) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Şifre Değiştir'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await context.read<AuthCubit>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

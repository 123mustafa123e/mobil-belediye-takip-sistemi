import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../ariza/bloc/ariza_cubit.dart';

class TakipScreen extends StatefulWidget {
  const TakipScreen({super.key});

  @override
  State<TakipScreen> createState() => _TakipScreenState();
}

class _TakipScreenState extends State<TakipScreen> {
  final _takipController = TextEditingController();

  @override
  void dispose() {
    _takipController.dispose();
    super.dispose();
  }

  Future<void> _sorgula() async {
    final id = _takipController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Takip numarası giriniz.')));
      return;
    }

    try {
      await context.read<ArizaCubit>().trackAriza(id);

      if (!mounted) {
        return;
      }

      final tracked = context.read<ArizaCubit>().state.trackedAriza;
      if (tracked == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kayıt bulunamadı.')));
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.arizaDetay,
        arguments: {'arizaId': tracked.id},
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Şikayet Takip')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<ArizaCubit, ArizaState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, size: 64, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Takip Numarası ile Sorgula',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _takipController,
                  decoration: const InputDecoration(
                    labelText: 'Takip Numarası',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _sorgula,
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sorgula'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

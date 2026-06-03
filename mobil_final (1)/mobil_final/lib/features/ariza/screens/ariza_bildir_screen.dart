import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../features/ariza/bloc/ariza_cubit.dart';
import '../../../features/auth/bloc/auth_cubit.dart';

class ArizaBildirScreen extends StatefulWidget {
  const ArizaBildirScreen({super.key});

  @override
  State<ArizaBildirScreen> createState() => _ArizaBildirScreenState();
}

class _ArizaBildirScreenState extends State<ArizaBildirScreen> {
  int _currentStep = 0;
  LatLng? _secilenKonum;
  String _kategori = AppConstants.kategoriSu;
  String _oncelik = AppConstants.oncelikNormal;
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _konumSec() async {
    final result = await Navigator.pushNamed(context, AppRoutes.mapScreen);
    if (result != null && result is LatLng) {
      setState(() {
        _secilenKonum = result;
      });
    }
  }

  Future<void> _submitAriza() async {
    final authState = context.read<AuthCubit>().state;
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce giriş yapmanız gerekiyor.')),
      );
      return;
    }

    if (_baslikController.text.trim().isEmpty ||
        _aciklamaController.text.trim().isEmpty ||
        _secilenKonum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen başlık, açıklama ve konum seçimi yapınız.'),
        ),
      );
      return;
    }

    try {
      await context.read<ArizaCubit>().submitAriza({
        'baslik': _baslikController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'kategori': _kategori,
        'oncelik': _oncelik,
        'adres': 'Seçilen konum',
        'enlem': _secilenKonum!.latitude,
        'boylam': _secilenKonum!.longitude,
        'vatandasId': user.id,
        'fotograflar': <String>[],
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arıza bildirimi başarıyla gönderildi.')),
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
    return BlocBuilder<ArizaCubit, ArizaState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Yeni Arıza Bildir')),
          body: Stack(
            children: [
              Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep += 1);
                  } else {
                    _submitAriza();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                steps: [
                  Step(
                    isActive: _currentStep >= 0,
                    title: const Text('Kategori'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _kategori,
                          decoration: const InputDecoration(
                            labelText: 'Arıza Kategorisi Seçin',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppConstants.kategoriSu,
                              child: Text('Su Arızası'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.kategoriElektrik,
                              child: Text('Elektrik Arızası'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.kategoriKarayolu,
                              child: Text('Yol/Kaldırım'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.kategoriDogalgaz,
                              child: Text('Doğalgaz'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _kategori = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _oncelik,
                          decoration: const InputDecoration(
                            labelText: 'Öncelik',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppConstants.oncelikDusuk,
                              child: Text('Düşük'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.oncelikNormal,
                              child: Text('Normal'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.oncelikYuksek,
                              child: Text('Yüksek'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.oncelikAcil,
                              child: Text('Acil'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _oncelik = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: _currentStep >= 1,
                    title: const Text('Detay'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _baslikController,
                          decoration: const InputDecoration(
                            labelText: 'Kısa Başlık',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _aciklamaController,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: _currentStep >= 2,
                    title: const Text('Konum'),
                    content: Column(
                      children: [
                        GestureDetector(
                          onTap: _konumSec,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _secilenKonum == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Haritadan Konum Seçmek İçin Dokunun',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Konum Seçildi',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_secilenKonum!.latitude.toStringAsFixed(5)}, ${_secilenKonum!.longitude.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _konumSec,
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            _secilenKonum == null
                                ? 'Haritayı Aç ve Konum Seç'
                                : 'Konumu Değiştir',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: _currentStep >= 3,
                    title: const Text('Onay'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bildirim Özeti',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Kategori: ${_kategori.toUpperCase()}'),
                        Text('Öncelik: ${_oncelik.toUpperCase()}'),
                        Text('Başlık: ${_baslikController.text}'),
                        Text('Açıklama: ${_aciklamaController.text}'),
                        Text(
                          'Konum: ${_secilenKonum != null ? "${_secilenKonum!.latitude.toStringAsFixed(5)}, ${_secilenKonum!.longitude.toStringAsFixed(5)}" : "Seçilmedi"}',
                        ),
                        const SizedBox(height: 16),
                        const Text('Bildiriminizi onaylıyor musunuz?'),
                      ],
                    ),
                  ),
                ],
              ),
              if (state.isSubmitting)
                const ColoredBox(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}

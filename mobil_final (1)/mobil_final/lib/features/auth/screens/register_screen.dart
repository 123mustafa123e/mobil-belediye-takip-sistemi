import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _tcController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _tcController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    final isLastStep = _currentStep == 2;
    if (isLastStep) {
      if (_formKey.currentState!.validate()) {
        // Form geçerli, kayıt işlemi yapılabilir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt Başarılı! Yönlendiriliyor...')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_currentStep == 2 ? 'Kaydı Tamamla' : 'Devam Et'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(_currentStep == 0 ? 'İptal' : 'Geri', style: const TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Kişisel Bilgiler', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _adController,
                      decoration: _buildInputDecoration('Ad', Icons.person),
                      validator: (value) => value!.isEmpty ? 'Ad alanı boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _soyadController,
                      decoration: _buildInputDecoration('Soyad', Icons.person_outline),
                      validator: (value) => value!.isEmpty ? 'Soyad alanı boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tcController,
                      decoration: _buildInputDecoration('TC Kimlik No', Icons.badge),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'TC Kimlik No boş bırakılamaz';
                        if (value.length != 11) return 'TC Kimlik No 11 haneli olmalıdır';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('İletişim Bilgileri', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('E-posta', Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'E-posta boş bırakılamaz';
                        if (!value.contains('@')) return 'Geçerli bir e-posta giriniz';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonController,
                      decoration: _buildInputDecoration('Telefon', Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Telefon alanı boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _adresController,
                      decoration: _buildInputDecoration('Adres', Icons.location_on),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Adres alanı boş bırakılamaz' : null,
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Güvenlik', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Şifre boş bırakılamaz';
                        if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordConfirmController,
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrar',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Şifre tekrarı boş bırakılamaz';
                        if (value != _passwordController.text) return 'Şifreler eşleşmiyor';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

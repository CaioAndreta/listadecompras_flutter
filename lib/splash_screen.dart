import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = Auth();

  @override
  void initState() {
    super.initState();
    _verificarStatusLogin();
  }

  Future<void> _verificarStatusLogin() async {
    try {
      // Executa a checagem assíncrona de forma limpa com await
      final bool isLoggedIn = await auth.verificarStatusLogin();

      if (!mounted) return;

      if (isLoggedIn) {
        // Usuário logado: manda para a Home e descarta a Splash
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Usuário não logado: manda para o Login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      // Tratamento de erro centralizado no bloco catch
      debugPrint('Erro ao verificar status de login: $error');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas, // O tom de cream quente do seu Design System
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary, // Laranja oficial e saturado para o loading
            ),
            const SizedBox(height: AppSpacing.lg), // 16px padronizado da escala
            Text(
              'Carregando...',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.ink, // Contraste elegante usando o tom café escuro
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

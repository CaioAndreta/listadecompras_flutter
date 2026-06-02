import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _verificarStatusLogin();
  }

  Future<void> _verificarStatusLogin() async {
    // await Future.delayed(const Duration(milliseconds: 1500));

    // Faz a leitura da chave 'UsuarioId'
    final usuarioId = await _storage.read(key: 'UsuarioId');
    if (!mounted) return;

    if (usuarioId != null && usuarioId.isNotEmpty) {
      // Usuário logado: manda para a Home e descarta a Splash
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Usuário não logado: manda para o Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Substitua pela cor principal do seu app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Carregando...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

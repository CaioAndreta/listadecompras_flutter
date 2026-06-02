import 'package:flutter/material.dart';
// Importe o seu arquivo onde está a classe Auth
import 'auth.dart';

class AuthGuard extends StatefulWidget {
  final Widget child; // A tela que queremos proteger

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final Auth _authService = Auth();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
  }

  Future<void> _verificarAcesso() async {
    final bool estaLogado = await _authService.verificarStatusLogin();

    if (!mounted) return;

    if (estaLogado) {
      // Se estiver logado, para de carregar e constrói a tela filha
      setState(() {
        _isLoading = false;
      });
    } else {
      // Se não estiver logado, redireciona para o login e mata a pilha
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto faz a verificação, mostra uma tela em branco ou um loading
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // A verificação passou, então exibe a tela original que foi envelopada
    return widget.child;
  }
}

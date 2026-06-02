import 'package:flutter/material.dart';
import 'package:flutter_application_1/detalhes.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/models/auth_guard.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/sign_up.dart';
import 'package:flutter_application_1/splash_screen.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Mercado',
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const SignUpScreen(),
        // Abaixo telas protegidas por autenticação
        '/home': (context) => const AuthGuard(child: HomeScreen()),
        '/detalhes': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ListaCompras;
          return AuthGuard(child: ListaDetalhesScreen(lista: args));
        },
      },
    );
  }
}

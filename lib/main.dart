import 'package:flutter/material.dart';
import 'package:flutter_application_1/detalhes.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/sign_up.dart';
import 'package:flutter_application_1/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/cadastro': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/detalhes': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ListaCompras;
          return ListaDetalhesScreen(lista: args);
        },
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/sign_up.dart';

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
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(), // Tela Home (a ser implementada)
        '/cadastro': (context) => const SignUpScreen(), // Tela de Cadastro (a ser implementada)
        '/login': (context) => const LoginScreen(), // Tela de Login
      },
    );
  }
}

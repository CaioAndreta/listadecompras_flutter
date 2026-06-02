import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<_LoginScreenState> loginScreenKey = GlobalKey();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _realizarLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String senha = _passwordController.text;

    final ApiClient apiClient = ApiClient();

    try {
      await apiClient.login(
        email: email,
        senha: senha,
        context: context,
        onError: (error) {
          if (mounted) {
            _mostrarToastErro(error);
          }
        },
      );
    } on DioException catch (e) {
      String mensagemErro = "Ocorreu um erro inesperado. Tente novamente.";

      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        mensagemErro = "E-mail ou senha incorretos.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagemErro = "Erro de conexão. Verifique sua internet.";
      }

      if (mounted) {
        _mostrarToastErro(mensagemErro);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarToastErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: AppColors.error, // Alinhado ao token de erro do DS
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl), // 24px padronizado
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Seja Bem-Vindo",
                    style: AppTextStyles.displayMd.copyWith(color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x2l), // 32px padronizado
                  // Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: Icon(Icons.email),
                      // Borda manual removida: controlada globalmente pelo AppTheme
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira seu e-mail";
                      }
                      if (!value.contains("@") || !value.contains(".")) {
                        return "Insira um formato de e-mail válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg), // 16px padronizado
                  // Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira sua senha";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl), // 24px padronizado
                  // Botão de Login / Indicador de Carregamento
                  ElevatedButton(
                    onPressed: _isLoading ? null : _realizarLogin,
                    // Estilização local removida: herdada inteiramente do AppTheme
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary, // Garante contraste sobre o botão laranja
                            ),
                          )
                        : const Text("Entrar"),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: const Text("Não tem uma conta? Cadastre-se"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

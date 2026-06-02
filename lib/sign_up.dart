import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Chave global para validar o formulário
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<_SignUpScreenState> signUpScreenKey = GlobalKey();

  // Controladores para capturar o texto dos campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Estado para controlar o carregamento do botão (loading)
  bool _isLoading = false;

  // Função que faz a requisição para a API
  Future<void> _realizarRegistro() async {
    // 1. Valida se os campos foram preenchidos corretamente localmente
    if (!_formKey.currentState!.validate()) {
      return; // Se houver erro local, interrompe o registro
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String senha = _passwordController.text;
    final String nome = _nameController.text.trim();

    final ApiClient apiClient = ApiClient();

    try {
      await apiClient.signUp(
        nome: nome,
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

      // 3. Trata os erros vindos da API
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

  // Função para exibir o SnackBar (Toast) de erro
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
    // Limpa os controladores quando a tela for fechada para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl), // 24px padronizado
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // Vincula a chave ao formulário
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Cadastre-se",
                    style: AppTextStyles.displayMd.copyWith(color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x2l), // 32px padronizado
                  // Campo de Nome
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      prefixIcon: Icon(Icons.person),
                      // Borda manual removida: controlada globalmente pelo AppTheme
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira seu nome";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg), // 16px padronizado
                  // Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email)),
                    // Validação local do campo de e-mail
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
                    obscureText: true, // Oculta os caracteres da senha
                    decoration: const InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock)),
                    // Validação local da senha
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
                  // Botão de Registro / Indicador de Carregamento
                  ElevatedButton(
                    onPressed: _isLoading ? null : _realizarRegistro,
                    // Estilização local removida: herdada inteiramente do AppTheme
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary, // Garante contraste sobre o botão primário
                            ),
                          )
                        : const Text("Registrar"),
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

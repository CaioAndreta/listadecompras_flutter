import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave global para validar o formulário
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<_LoginScreenState> loginScreenKey = GlobalKey();

  // Controladores para capturar o texto dos campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Estado para controlar o carregamento do botão (loading)
  bool _isLoading = false;

  // Função que faz a requisição para a API
  Future<void> _realizarLogin() async {
    // 1. Valida se os campos foram preenchidos corretamente localmente
    if (!_formKey.currentState!.validate()) {
      return; // Se houver erro local, interrompe o login
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

      // 3. Trata os erros vindos da API (ex: usuário ou senha incorretos)
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        mensagemErro = "E-mail ou senha incorretos.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagemErro = "Erro de conexão. Verifique sua internet.";
      }

      if (mounted) {
        // Exibe o "Toast" (SnackBar) com o erro da API
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
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating, // Deixa o alerta flutuante como um toast
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Limpa os controladores quando a tela for fechada para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // Vincula a chave ao formulário
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Seja Bem-Vindo",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    // Validação local do campo de e-mail
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira seu e-mail";
                      }
                      if (!value.contains("@") || !value.contains(".")) {
                        return "Insira um formato de e-mail válido";
                      }
                      return null; // Retornar null significa que está tudo certo
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Oculta os caracteres da senha
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 24),

                  // Botão de Login / Indicador de Carregamento
                  ElevatedButton(
                    onPressed: _isLoading ? null : _realizarLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Entrar"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Aqui você pode implementar a navegação para a tela de cadastro
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

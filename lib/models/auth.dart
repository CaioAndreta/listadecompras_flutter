import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth {
  // Cria a instância do storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Verifica se existe um 'UsuarioId' salvo no storage.
  /// Retorna [true] se estiver logado, e [false] se não estiver.
  Future<bool> verificarStatusLogin() async {
    try {
      final String? usuarioId = await _storage.read(key: 'UsuarioId');

      // Retorna true apenas se o ID não for nulo e não for uma string vazia
      return usuarioId != null && usuarioId.isNotEmpty;
    } catch (e) {
      // Caso ocorra algum erro na leitura (ex: storage corrompido),
      // garantimos que o app não quebre e trate o usuário como deslogado.
      debugPrint('Erro ao ler o status de login: $e');
      return false;
    }
  }

  /// Bônus: Já deixo aqui a função de logout pronta para você usar!
  Future<void> fazerLogout() async {
    try {
      // Remove especificamente o ID ou limpa tudo com deleteAll()
      await _storage.delete(key: 'UsuarioId');
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }
}

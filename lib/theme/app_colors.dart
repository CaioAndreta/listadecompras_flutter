import 'package:flutter/material.dart';

// =============================================================================
// COLOR TOKENS — Zapier Design System
// Warm-cream neutrals, coffee ink, single saturated orange CTA accent.
// =============================================================================

abstract class AppColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Laranja CTA — use APENAS para botões primários e ações de conversão.
  static const Color primary = Color(0xFFFF4F00);

  /// Branco quente — texto sobre fundo laranja.
  static const Color onPrimary = Color(0xFFFFFEFB);

  // ---------------------------------------------------------------------------
  // Escala de Ink (café quente — nunca preto puro)
  // ---------------------------------------------------------------------------

  /// Ink principal — headlines, textos de alta ênfase.
  static const Color ink = Color(0xFF201515);

  /// Ink suave — variante levemente mais clara.
  static const Color inkSoft = Color(0xFF2F2A26);

  /// Ink médio — superfícies escuras (footer, cards dark).
  static const Color inkMid = Color(0xFF36342E);

  // ---------------------------------------------------------------------------
  // Escala de Body (texto corrido)
  // ---------------------------------------------------------------------------

  /// Corpo padrão — parágrafos e textos secundários.
  static const Color body = Color(0xFF605D52);

  /// Corpo médio — placeholders, labels desabilitados.
  static const Color bodyMid = Color(0xFF939084);

  /// Mute — bordas sutis, divisores.
  static const Color mute = Color(0xFFC5C0B1);

  // ---------------------------------------------------------------------------
  // Canvas (cream quente — nunca branco puro)
  // ---------------------------------------------------------------------------

  /// Canvas principal — background de telas e hero.
  static const Color canvas = Color(0xFFFFFEFB);

  /// Canvas suave — fundo de cards e bandas de conteúdo.
  static const Color canvasSoft = Color(0xFFF8F4F0);

  // ---------------------------------------------------------------------------
  // Error (Material 3 padrão)
  // ---------------------------------------------------------------------------

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFEFB);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

// =============================================================================
// TEXT STYLES — Zapier Design System
// Fonte: Open Sans.
// Nota: Degular Display (proprietária) substituída por Open Sans weight 500
// nos estilos de display e eyebrow. Para usar Degular, troque o fontFamily
// nos estilos marcados com [Degular].
// =============================================================================

abstract class AppTextStyles {
  // ---------------------------------------------------------------------------
  // Display — escala hero [Degular]
  // ---------------------------------------------------------------------------

  /// Hero headline — 56px / w500. Usar em telas de boas-vindas e banners.
  static const TextStyle displayXl = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 56,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Sub-hero — 48px / w500.
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Section display — 32px / w500 / tracking +1px. [Degular]
  static const TextStyle displayMd = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.125,
    letterSpacing: 1,
    color: AppColors.ink,
  );

  // ---------------------------------------------------------------------------
  // Sub-display — Open Sans
  // ---------------------------------------------------------------------------

  /// 48px / w500 — sub-display grande.
  static const TextStyle displaySubLg = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.04,
    color: AppColors.ink,
  );

  /// 32px / w400 — sub-display médio.
  static const TextStyle displaySubMd = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: AppColors.ink,
  );

  /// 24px / w600 — títulos de card e seção.
  static const TextStyle displaySubSm = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  /// 20px / w700 — micro-headings inline.
  static const TextStyle displayXs = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );

  // ---------------------------------------------------------------------------
  // Body — texto corrido
  // ---------------------------------------------------------------------------

  /// Lead paragraph — 20px / w400.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.2,
    color: AppColors.body,
  );

  /// Corpo padrão — 18px / w400.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.body,
  );

  /// Corpo em negrito — 18px / w600.
  static const TextStyle bodyMdStrong = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.ink,
  );

  /// Corpo secundário — 16px / w400.
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.body,
  );

  /// Corpo secundário em negrito — 16px / w600.
  static const TextStyle bodySmStrong = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.ink,
  );

  /// Fine print / legenda — 14px / w400.
  static const TextStyle caption = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.bodyMid,
  );

  // ---------------------------------------------------------------------------
  // Eyebrow — label UPPERCASE [Degular]
  // Use com .toUpperCase() no texto — nunca hardcode uppercase aqui.
  // ---------------------------------------------------------------------------

  /// Eyebrow UPPERCASE — 14px / w500 / tracking +1px.
  static const TextStyle eyebrowUppercase = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 1,
    color: AppColors.ink,
  );

  // ---------------------------------------------------------------------------
  // Botões
  // ---------------------------------------------------------------------------

  /// Label de botão primário — 18px / w600.
  static const TextStyle buttonMd = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.onPrimary,
  );

  /// Label de botão pequeno — 14.4px / w700.
  static const TextStyle buttonSm = TextStyle(
    fontFamily: 'Open Sans',
    fontSize: 14.4,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.144,
    color: AppColors.ink,
  );
}

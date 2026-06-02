import 'package:flutter/material.dart';
import 'app_colors.dart';

// =============================================================================
// CONSTANTS — Zapier Design System
// Spacing · Border Radius · BoxDecorations · EdgeInsets
// =============================================================================

// -----------------------------------------------------------------------------
// SPACING — base unit: 4px
// -----------------------------------------------------------------------------

abstract class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double x2l = 32;
  static const double x3l = 48;
  static const double x4l = 64;
}

// -----------------------------------------------------------------------------
// BORDER RADIUS
// -----------------------------------------------------------------------------

abstract class AppRadius {
  static const double none = 0;

  /// Inputs e pills inline — 6px.
  static const double sm = 6;

  /// Botões e cards — raio canônico da marca — 12px.
  static const double md = 12;

  /// Pills de status e badges — 9999px.
  static const double pill = 9999;

  // BorderRadius prontos para uso direto
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius topMd = BorderRadius.vertical(top: Radius.circular(md));
}

// -----------------------------------------------------------------------------
// BOX DECORATIONS — espelham os componentes do design system
// -----------------------------------------------------------------------------

abstract class AppDecorations {
  /// card-content / card-feature-cream — superfície cream suave.
  static BoxDecoration get cardContent => BoxDecoration(
        color: AppColors.canvasSoft,
        borderRadius: AppRadius.mdAll,
      );

  /// card-feature-dark — polaridade invertida (fundo escuro).
  static BoxDecoration get cardFeatureDark => BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadius.mdAll,
      );

  /// pricing-card — com borda hairline 1px.
  static BoxDecoration get pricingCard => BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.ink, width: 1),
      );

  /// pricing-card-featured — polaridade invertida, sem borda.
  static BoxDecoration get pricingCardFeatured => BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadius.mdAll,
      );

  /// hero-band — fundo cream canvas padrão.
  static const BoxDecoration heroBand = BoxDecoration(
    color: AppColors.canvas,
  );

  /// hero-band-dark — fundo ink escuro.
  static const BoxDecoration heroBandDark = BoxDecoration(
    color: AppColors.ink,
  );

  /// content-band-cream — fundo canvas-soft para seções de conteúdo.
  static const BoxDecoration contentBandCream = BoxDecoration(
    color: AppColors.canvasSoft,
  );

  /// content-band-light — fundo canvas para seções abertas.
  static const BoxDecoration contentBandLight = BoxDecoration(
    color: AppColors.canvas,
  );

  /// badge-pill — pill de metadata e tags.
  static BoxDecoration get badgePill => BoxDecoration(
        color: AppColors.canvasSoft,
        borderRadius: AppRadius.pillAll,
      );

  /// footer — fundo ink escuro.
  static const BoxDecoration footer = BoxDecoration(
    color: AppColors.ink,
  );
}

// -----------------------------------------------------------------------------
// EDGE INSETS — paddings semânticos prontos para uso
// -----------------------------------------------------------------------------

abstract class AppPadding {
  /// Interior de cards — 24px em todos os lados.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.xl);

  /// Bandas de hero e seções — 64px vertical, 24px horizontal.
  static const EdgeInsets band = EdgeInsets.symmetric(
    vertical: AppSpacing.x4l,
    horizontal: AppSpacing.xl,
  );

  /// Nav bar — 12px vertical, 24px horizontal.
  static const EdgeInsets nav = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
    horizontal: AppSpacing.xl,
  );

  /// Botão primário — 12px vertical, 24px horizontal.
  static const EdgeInsets buttonPrimary = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
    horizontal: AppSpacing.xl,
  );

  /// Botão pequeno / text button — 8px vertical, 16px horizontal.
  static const EdgeInsets buttonSmall = EdgeInsets.symmetric(
    vertical: AppSpacing.sm,
    horizontal: AppSpacing.lg,
  );

  /// Badge pill — 4px vertical, 12px horizontal.
  static const EdgeInsets badgePill = EdgeInsets.symmetric(
    vertical: AppSpacing.xs,
    horizontal: AppSpacing.md,
  );

  /// Footer — 48px vertical, 24px horizontal.
  static const EdgeInsets footer = EdgeInsets.symmetric(
    vertical: AppSpacing.x3l,
    horizontal: AppSpacing.xl,
  );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_constants.dart';

// =============================================================================
// APP THEME — Zapier Design System
// Composição principal do ThemeData (Material 3).
// =============================================================================

ThemeData appTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    // Brand
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.canvasSoft,
    onPrimaryContainer: AppColors.ink,
    // Secondary (coffee ink)
    secondary: AppColors.ink,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: AppColors.inkMid,
    onSecondaryContainer: AppColors.onPrimary,
    // Tertiary (muted)
    tertiary: AppColors.bodyMid,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.canvasSoft,
    onTertiaryContainer: AppColors.ink,
    // Surface & background
    surface: AppColors.canvas,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.canvasSoft,
    onSurfaceVariant: AppColors.body,
    // Error
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    // Outline
    outline: AppColors.ink,
    outlineVariant: AppColors.mute,
    // Misc
    shadow: AppColors.inkSoft,
    scrim: AppColors.ink,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.onPrimary,
    inversePrimary: AppColors.primary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.canvas,
    fontFamily: 'Open Sans',

    // -------------------------------------------------------------------------
    // Text Theme
    // -------------------------------------------------------------------------
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayXl,
      displayMedium: AppTextStyles.displayLg,
      displaySmall: AppTextStyles.displayMd,
      headlineLarge: AppTextStyles.displaySubLg,
      headlineMedium: AppTextStyles.displaySubMd,
      headlineSmall: AppTextStyles.displaySubSm,
      titleLarge: AppTextStyles.displayXs,
      titleMedium: AppTextStyles.bodyMdStrong,
      titleSmall: AppTextStyles.bodySmStrong,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.buttonMd,
      labelMedium: AppTextStyles.buttonSm,
      labelSmall: AppTextStyles.caption,
    ),

    // -------------------------------------------------------------------------
    // AppBar
    // -------------------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Open Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      iconTheme: IconThemeData(color: AppColors.ink),
      actionsIconTheme: IconThemeData(color: AppColors.ink),
    ),

    // -------------------------------------------------------------------------
    // Botão primário — laranja CTA
    // -------------------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: AppPadding.buttonPrimary,
        minimumSize: const Size(0, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: AppTextStyles.buttonMd.copyWith(color: AppColors.onPrimary),
      ),
    ),

    // -------------------------------------------------------------------------
    // Botão secundário — ink fill
    // -------------------------------------------------------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: AppPadding.buttonPrimary,
        minimumSize: const Size(0, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: AppTextStyles.buttonMd.copyWith(color: AppColors.onPrimary),
      ),
    ),

    // -------------------------------------------------------------------------
    // Botão outline / terciário
    // -------------------------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 1),
        padding: AppPadding.buttonPrimary,
        minimumSize: const Size(0, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: AppTextStyles.buttonMd.copyWith(color: AppColors.ink),
      ),
    ),

    // -------------------------------------------------------------------------
    // Text button — CTA textual (dentro de cards e nav)
    // -------------------------------------------------------------------------
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.transparent,
        padding: AppPadding.buttonSmall,
        minimumSize: const Size(0, 40),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: AppTextStyles.buttonSm.copyWith(color: AppColors.ink),
      ),
    ),

    // -------------------------------------------------------------------------
    // Input / Text Field
    // -------------------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.canvas,
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.bodyMid),
      labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.body),
      floatingLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.ink),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: AppColors.ink, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: AppColors.ink, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
    ),

    // -------------------------------------------------------------------------
    // Card
    // -------------------------------------------------------------------------
    cardTheme: const CardThemeData(
      color: AppColors.canvasSoft,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
    ),

    // -------------------------------------------------------------------------
    // Chip / Badge Pill
    // -------------------------------------------------------------------------
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.canvasSoft,
      labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.ink),
      side: BorderSide.none,
      padding: AppPadding.badgePill,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
    ),

    // -------------------------------------------------------------------------
    // Bottom Navigation Bar
    // -------------------------------------------------------------------------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.canvas,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.bodyMid,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontFamily: 'Open Sans', fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: 'Open Sans', fontSize: 12, fontWeight: FontWeight.w400),
    ),

    // -------------------------------------------------------------------------
    // Navigation Bar (Material 3)
    // -------------------------------------------------------------------------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.canvas,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.bodyMid);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600);
        }
        return AppTextStyles.caption.copyWith(color: AppColors.bodyMid);
      }),
    ),

    // -------------------------------------------------------------------------
    // Navigation Drawer
    // -------------------------------------------------------------------------
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),

    // -------------------------------------------------------------------------
    // Navigation Rail
    // -------------------------------------------------------------------------
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.canvas,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.bodyMid),
      selectedLabelTextStyle: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: AppTextStyles.caption.copyWith(color: AppColors.bodyMid),
      indicatorColor: AppColors.primary.withOpacity(0.15),
    ),

    // -------------------------------------------------------------------------
    // Divider
    // -------------------------------------------------------------------------
    dividerTheme: const DividerThemeData(color: AppColors.mute, thickness: 1, space: 1),

    // -------------------------------------------------------------------------
    // List Tile
    // -------------------------------------------------------------------------
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.canvasSoft,
      selectedColor: AppColors.primary,
      iconColor: AppColors.body,
      textColor: AppColors.ink,
      titleTextStyle: AppTextStyles.bodyMd,
      subtitleTextStyle: AppTextStyles.bodySm,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
    ),

    // -------------------------------------------------------------------------
    // Dialog
    // -------------------------------------------------------------------------
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      titleTextStyle: AppTextStyles.displaySubSm,
      contentTextStyle: AppTextStyles.bodyMd,
    ),

    // -------------------------------------------------------------------------
    // Snack Bar / Toast
    // -------------------------------------------------------------------------
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppTextStyles.bodySm.copyWith(color: AppColors.onPrimary),
      actionTextColor: AppColors.primary,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      behavior: SnackBarBehavior.floating,
    ),

    // -------------------------------------------------------------------------
    // Bottom Sheet
    // -------------------------------------------------------------------------
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.topMd),
    ),

    // -------------------------------------------------------------------------
    // Switch / Toggle
    // -------------------------------------------------------------------------
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
        return AppColors.bodyMid;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.mute;
      }),
    ),

    // -------------------------------------------------------------------------
    // Checkbox
    // -------------------------------------------------------------------------
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.ink, width: 1.5),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
    ),

    // -------------------------------------------------------------------------
    // Radio
    // -------------------------------------------------------------------------
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.ink;
      }),
    ),

    // -------------------------------------------------------------------------
    // Slider
    // -------------------------------------------------------------------------
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.mute,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x1AFF4F00),
      valueIndicatorColor: AppColors.ink,
      valueIndicatorTextStyle: AppTextStyles.caption,
    ),

    // -------------------------------------------------------------------------
    // Progress Indicator
    // -------------------------------------------------------------------------
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.mute,
      circularTrackColor: AppColors.mute,
    ),

    // -------------------------------------------------------------------------
    // Tab Bar
    // -------------------------------------------------------------------------
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.ink,
      unselectedLabelColor: AppColors.bodyMid,
      labelStyle: AppTextStyles.bodySmStrong,
      unselectedLabelStyle: AppTextStyles.bodySm,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.mute,
    ),

    // -------------------------------------------------------------------------
    // Tooltip
    // -------------------------------------------------------------------------
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(color: AppColors.inkSoft, borderRadius: AppRadius.smAll),
      textStyle: AppTextStyles.caption.copyWith(color: AppColors.onPrimary),
    ),

    // -------------------------------------------------------------------------
    // Icon
    // -------------------------------------------------------------------------
    iconTheme: const IconThemeData(color: AppColors.ink, size: 24),

    // -------------------------------------------------------------------------
    // FloatingActionButton — laranja primário
    // -------------------------------------------------------------------------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: CircleBorder(),
    ),
  );
}

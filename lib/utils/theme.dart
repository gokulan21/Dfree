import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.accentCyan,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      cardColor: AppColors.cardColor,
      fontFamily: 'Inter',
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: AppSizes.fontSizeXLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textWhite, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppColors.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textWhite, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textWhite, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.textGrey, fontSize: 14),
        labelMedium: TextStyle(color: AppColors.textGrey, fontSize: 12),
        labelSmall: TextStyle(color: AppColors.textGrey, fontSize: 10),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          side: const BorderSide(color: AppColors.accentCyan),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        hintStyle: const TextStyle(color: AppColors.textGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textWhite,
        size: AppSizes.iconSizeMedium,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.bgSecondary,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppSizes.largeBorderRadius),
            bottomRight: Radius.circular(AppSizes.largeBorderRadius),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textWhite,
          fontSize: AppSizes.fontSizeXLarge,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textWhite,
          fontSize: AppSizes.fontSizeMedium,
        ),
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardColor,
        contentTextStyle: const TextStyle(color: AppColors.textWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.smallBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentCyan;
          }
          return AppColors.textGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentCyan.withOpacity(0.5);
          }
          return AppColors.borderColor;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentCyan;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textWhite),
        side: const BorderSide(color: AppColors.borderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentCyan;
          }
          return AppColors.borderColor;
        }),
      ),
      
      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accentCyan,
        inactiveTrackColor: AppColors.borderColor,
        thumbColor: AppColors.accentCyan,
        overlayColor: AppColors.accentCyan,
        valueIndicatorColor: AppColors.accentCyan,
        valueIndicatorTextStyle: TextStyle(color: AppColors.textWhite),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentCyan,
        linearTrackColor: AppColors.borderColor,
        circularTrackColor: AppColors.borderColor,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.accentCyan,
        unselectedLabelColor: AppColors.textGrey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.accentCyan, width: 2),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textWhite,
        iconColor: AppColors.textWhite,
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.accentCyan,
        selectedColor: AppColors.textWhite,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPink,
        foregroundColor: AppColors.textWhite,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
      ),
      
      useMaterial3: true,
    );
  }
  
  // Custom gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.accentCyan, AppColors.accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [AppColors.cardColor, AppColors.bgSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.successGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [AppColors.warningYellow, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [AppColors.dangerRed, Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
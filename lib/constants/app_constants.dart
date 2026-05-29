import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'FinanceTracker';
  static const String appVersion = '1.0.0';

  // Professional Color Palette
  static const Color primaryColor = Color(0xFF5B61E0);
  static const Color gradientEnd = Color(0xFF8E54E9);
  static const Color primaryOrange = Color(0xFF5B61E0);
  static const Color primaryRed = Color(0xFF8E54E9);

  // UI Colors
  static const Color backgroundColor = Color(0xFFF4F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF8F95A3);
  static const Color dividerColor = Color(0xFFE8E9EE);
  static const Color successColor = Color(0xFF2ED573);
  static const Color warningColor = Color(0xFFFFA502);
  static const Color errorColor = Color(0xFFFF4757);
  static const Color infoColor = Color(0xFF5352ED);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF5B61E0), // Purple Blue
    Color(0xFF8E54E9), // Purple
    Color(0xFF2ED573), // Green
    Color(0xFFFF4757), // Red
    Color(0xFFFFA502), // Orange
    Color(0xFF1E90FF), // Blue
    Color(0xFFFF6B81), // Pink
    Color(0xFF00CEC9), // Teal
    Color(0xFFA29BFE), // Light Purple
    Color(0xFFFD79A8), // Light Pink
  ];

  // Default Categories
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {'name': 'Makanan', 'icon': 'restaurant', 'color': '#FF6B81'},
    {'name': 'Transportasi', 'icon': 'directions_car', 'color': '#1E90FF'},
    {'name': 'Belanja', 'icon': 'shopping_cart', 'color': '#A29BFE'},
    {'name': 'Tagihan', 'icon': 'receipt', 'color': '#FF4757'},
    {'name': 'Hiburan', 'icon': 'movie', 'color': '#FFA502'},
    {'name': 'Kesehatan', 'icon': 'local_hospital', 'color': '#2ED573'},
    {'name': 'Pendidikan', 'icon': 'school', 'color': '#00CEC9'},
    {'name': 'Lainnya', 'icon': 'more_horiz', 'color': '#8F95A3'},
  ];

  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {'name': 'Gaji', 'icon': 'work', 'color': '#2ED573'},
    {'name': 'Bonus', 'icon': 'card_giftcard', 'color': '#FFA502'},
    {'name': 'Investasi', 'icon': 'trending_up', 'color': '#1E90FF'},
    {'name': 'Hadiah', 'icon': 'redeem', 'color': '#A29BFE'},
    {'name': 'Lainnya', 'icon': 'more_horiz', 'color': '#8F95A3'},
  ];

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Padding & Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Database
  static const String databaseName = 'finance_tracker.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyOnboarded = 'onboarded';
  static const String keyPinSet = 'pin_set';
  static const String keyDarkMode = 'dark_mode';
  static const String keyCurrency = 'currency';

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF5B61E0),
    Color(0xFF8E54E9),
    Color(0xFF2ED573),
    Color(0xFFFF4757),
    Color(0xFFFFA502),
    Color(0xFF1E90FF),
    Color(0xFFFF6B81),
    Color(0xFF00CEC9),
    Color(0xFFA29BFE),
    Color(0xFFFD79A8),
  ];
}

import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'FinanceTracker';
  static const String appVersion = '1.0.0';

  // BNI Branding Colors
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color primaryRed = Color(0xFFE63946);
  static const Color gradientStart = Color(0xFFFF6B00);
  static const Color gradientEnd = Color(0xFFE63946);


  // UI Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFFF6B00), // Orange
    Color(0xFFE63946), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Amber
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  // Default Categories
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {'name': 'Makanan', 'icon': 'restaurant', 'color': '#FF6B00'},
    {'name': 'Transportasi', 'icon': 'directions_car', 'color': '#2196F3'},
    {'name': 'Belanja', 'icon': 'shopping_cart', 'color': '#E91E63'},
    {'name': 'Tagihan', 'icon': 'receipt', 'color': '#F44336'},
    {'name': 'Hiburan', 'icon': 'movie', 'color': '#9C27B0'},
    {'name': 'Kesehatan', 'icon': 'local_hospital', 'color': '#4CAF50'},
    {'name': 'Pendidikan', 'icon': 'school', 'color': '#00BCD4'},
    {'name': 'Lainnya', 'icon': 'more_horiz', 'color': '#607D8B'},
  ];

  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {'name': 'Gaji', 'icon': 'work', 'color': '#4CAF50'},
    {'name': 'Bonus', 'icon': 'card_giftcard', 'color': '#FF9800'},
    {'name': 'Investasi', 'icon': 'trending_up', 'color': '#2196F3'},
    {'name': 'Hadiah', 'icon': 'redeem', 'color': '#E91E63'},
    {'name': 'Lainnya', 'icon': 'more_horiz', 'color': '#607D8B'},
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
    Color(0xFFFF6B00),
    Color(0xFFE63946),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];
}

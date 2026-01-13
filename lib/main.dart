import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return FutureBuilder<bool>(
            future: userProvider.isDarkMode(),
            builder: (context, snapshot) {
              final isDarkMode = snapshot.data ?? false;

              return MaterialApp(
                title: 'Finance Tracker',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: const SplashScreen(),
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/splash':
                      return MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      );
                    case '/main':
                      return MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      );
                    default:
                      return MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      );
                  }
                },
                // Add responsive builder for old/small devices
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      // Limit text scale factor to prevent overflow on small screens
                      textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                    ),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

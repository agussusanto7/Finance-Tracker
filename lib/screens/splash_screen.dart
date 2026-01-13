import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/pin_screen.dart';
import 'home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.defaultAnimationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final onboarded = await userProvider.isOnboarded();

    if (!onboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // Check if user exists and PIN is set
      await userProvider.loadUser();
      final user = userProvider.user;
      final pinSet = await userProvider.isPinSet();

      // Always show PIN screen if user exists and has PIN set
      if (user != null && user.pin != null && user.pin!.isNotEmpty && pinSet) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PinScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: AppTheme.appBarGradient,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isSmallScreen ? screenWidth * 0.25 : 120,
                      height: isSmallScreen ? screenWidth * 0.25 : 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: isSmallScreen ? screenWidth * 0.12 : 60,
                        color: AppConstants.primaryOrange,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? screenWidth * 0.06 : AppConstants.paddingLarge),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? screenWidth * 0.07 : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? screenWidth * 0.03 : AppConstants.paddingSmall),
                    Text(
                      'Kelola Keuangan dengan Cerdas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? screenWidth * 0.04 : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? screenWidth * 0.12 : AppConstants.paddingXLarge * 2),
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

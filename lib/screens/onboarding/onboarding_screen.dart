import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../auth/pin_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      title: 'Catat Pemasukan & Pengeluaran',
      description:
          'Pantau semua keuangan Anda dengan mudah dan cepat di satu aplikasi',
      icon: Icons.account_balance_wallet,
      color: AppConstants.primaryOrange,
    ),
    OnboardingModel(
      title: 'Analisis Pengeluaran',
      description:
          'Dapatkan wawasan mendalam tentang kebiasaan pengeluaran Anda',
      icon: Icons.pie_chart,
      color: AppConstants.primaryRed,
    ),
    OnboardingModel(
      title: 'Atur Budget Bulanan',
      description:
          'Tetapkan batas pengeluaran dan capai tujuan keuangan Anda',
      icon: Icons.savings,
      color: AppConstants.infoColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.setOnboarded(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive breakpoints
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenHeight < 600;
            final isVerySmallScreen = screenHeight < 500;
            final isMediumScreen = screenHeight >= 600 && screenHeight < 800;

            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(
                        _pages[index],
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        isSmallScreen: isSmallScreen,
                        isVerySmallScreen: isVerySmallScreen,
                        isMediumScreen: isMediumScreen,
                      );
                    },
                  ),
                ),
                _buildBottomSection(
                  isSmallScreen: isSmallScreen,
                  isVerySmallScreen: isVerySmallScreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(
    OnboardingModel page, {
    required double screenHeight,
    required double screenWidth,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
    required bool isMediumScreen,
  }) {
    // Responsive sizing
    double iconContainerSize;
    double iconSize;
    double titleFontSize;
    double descriptionFontSize;
    double verticalSpacing;
    double horizontalPadding;

    if (isVerySmallScreen) {
      // HP jadul dengan layar sangat kecil (< 500px height)
      iconContainerSize = screenWidth * 0.3;
      iconSize = iconContainerSize * 0.5;
      titleFontSize = 18;
      descriptionFontSize = 13;
      verticalSpacing = 12;
      horizontalPadding = 16;
    } else if (isSmallScreen) {
      // HP kecil (500-600px height)
      iconContainerSize = screenWidth * 0.35;
      iconSize = iconContainerSize * 0.5;
      titleFontSize = 20;
      descriptionFontSize = 14;
      verticalSpacing = 16;
      horizontalPadding = 20;
    } else if (isMediumScreen) {
      // HP medium (600-800px height)
      iconContainerSize = screenWidth * 0.4;
      iconSize = iconContainerSize * 0.5;
      titleFontSize = 24;
      descriptionFontSize = 15;
      verticalSpacing = 24;
      horizontalPadding = 24;
    } else {
      // HP besar/modern (> 800px height)
      iconContainerSize = screenWidth * 0.45;
      iconSize = iconContainerSize * 0.5;
      titleFontSize = 28;
      descriptionFontSize = 16;
      verticalSpacing = 32;
      horizontalPadding = 32;
    }

    // Batasi ukuran maksimum
    iconContainerSize = iconContainerSize.clamp(80.0, 220.0);
    iconSize = iconSize.clamp(40.0, 110.0);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight - _getBottomSectionHeight(isSmallScreen, isVerySmallScreen),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isVerySmallScreen ? 8 : 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer atas yang fleksibel
              SizedBox(height: isVerySmallScreen ? 8 : verticalSpacing),
              
              // Icon Container
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: iconSize,
                  color: page.color,
                ),
              ),
              
              SizedBox(height: verticalSpacing),
              
              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    page.title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
              
              SizedBox(height: isVerySmallScreen ? 8 : 12),
              
              // Description
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmallScreen ? 8 : 16,
                ),
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Spacer bawah yang fleksibel
              SizedBox(height: isVerySmallScreen ? 8 : verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  double _getBottomSectionHeight(bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) return 100;
    if (isSmallScreen) return 120;
    return 150;
  }

  Widget _buildBottomSection({
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    final double padding = isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24);
    final double buttonHeight = isVerySmallScreen ? 44 : (isSmallScreen ? 48 : 52);
    final double buttonFontSize = isVerySmallScreen ? 14 : 16;
    final double indicatorSpacing = isVerySmallScreen ? 12 : 20;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildPageIndicator(
                index == _currentPage,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ),
          
          SizedBox(height: indicatorSpacing),
          
          // Button Lanjut/Mulai
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ),
          ),
          
          // Button Lewati (hanya tampil jika bukan halaman terakhir)
          if (_currentPage < _pages.length - 1)
            SizedBox(
              height: isVerySmallScreen ? 32 : 40,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isVerySmallScreen ? 4 : 8,
                  ),
                ),
                child: Text(
                  'Lewati',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 13 : 14,
                  ),
                ),
              ),
            )
          else
            SizedBox(height: isVerySmallScreen ? 32 : 40),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive, {required bool isSmallScreen}) {
    final double height = isSmallScreen ? 6 : 8;
    final double activeWidth = isSmallScreen ? 18 : 24;
    final double inactiveWidth = isSmallScreen ? 6 : 8;

    return AnimatedContainer(
      duration: AppConstants.fastAnimationDuration,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
      height: height,
      width: isActive ? activeWidth : inactiveWidth,
      decoration: BoxDecoration(
        color: isActive ? AppConstants.primaryOrange : AppConstants.dividerColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

class OnboardingModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
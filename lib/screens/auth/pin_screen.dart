import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_provider.dart';
import '../home/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final List<String> _pin = [];
  String _errorMessage = '';
  int _failedAttempts = 0;

  void _addPinDigit(String digit) {
    setState(() {
      _errorMessage = '';
      if (_pin.length < 6) {
        _pin.add(digit);
        if (_pin.length == 6) {
          _verifyPin();
        }
      }
    });
  }

  void _removePinDigit() {
    setState(() {
      _errorMessage = '';
      if (_pin.isNotEmpty) {
        _pin.removeLast();
      }
    });
  }

  Future<void> _verifyPin() async {
    // Beri sedikit jeda agar UI sempat merender (menampilkan) titik ke-6
    await Future.delayed(const Duration(milliseconds: 300));

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final enteredPin = _pin.join();

    // Ensure user data is loaded
    if (userProvider.user == null) {
      await userProvider.loadUser();
    }

    if (userProvider.user?.pin == enteredPin) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'PIN salah';
        _failedAttempts++;
        _pin.clear();
      });
      HapticFeedback.vibrate();

      if (_failedAttempts >= 3) {
        _showLockedDialog();
      }
    }
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Akun Terkunci'),
        content: const Text(
          'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _failedAttempts = 0;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa PIN?'),
        content: const Text(
          'Untuk mereset PIN, Anda harus keluar dari aplikasi dan masuk kembali. '
          'Setelah masuk, Anda akan diminta untuk membuat PIN baru.\n\n'
          'Apakah Anda ingin keluar sekarang?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Keluar Akun'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Hapus sesi
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.appBarGradient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;
              
              // Responsive breakpoints
              final isVerySmallScreen = screenHeight < 500;
              final isSmallScreen = screenHeight >= 500 && screenHeight < 600;
              final isMediumScreen = screenHeight >= 600 && screenHeight < 750;
              
              // Calculate responsive sizes
              final iconSize = _getIconSize(screenHeight, screenWidth);
              final iconContainerSize = iconSize * 2;
              final titleFontSize = _getTitleFontSize(screenHeight);
              final subtitleFontSize = _getSubtitleFontSize(screenHeight);
              final topPadding = _getTopPadding(screenHeight);
              final sectionSpacing = _getSectionSpacing(screenHeight);
              
              // Number pad sizing
              final numberButtonSize = _getNumberButtonSize(screenHeight, screenWidth);
              final numberFontSize = _getNumberFontSize(screenHeight);
              final numberPadVerticalPadding = _getNumberPadVerticalPadding(screenHeight);
              final numberPadHorizontalPadding = _getNumberPadHorizontalPadding(screenWidth);
              
              // PIN dots sizing
              final pinDotSize = _getPinDotSize(screenHeight);
              final pinDotSpacing = _getPinDotSpacing(screenWidth);

              return Column(
                children: [
                  // Top section with icon, title, PIN dots
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - _getNumberPadHeight(screenHeight, numberButtonSize, numberPadVerticalPadding),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 16 : AppConstants.paddingLarge,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: topPadding),
                              
                              // Lock Icon
                              Container(
                                width: iconContainerSize,
                                height: iconContainerSize,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock,
                                  size: iconSize,
                                  color: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: sectionSpacing),
                              
                              // Title
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Masukkan PIN',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: titleFontSize,
                                      ),
                                ),
                              ),
                              
                              SizedBox(height: isVerySmallScreen ? 4 : 8),
                              
                              // Subtitle
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Masukkan 6 digit PIN untuk masuk',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: subtitleFontSize,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              SizedBox(height: sectionSpacing),
                              
                              // PIN Dots
                              _buildPinDots(
                                dotSize: pinDotSize,
                                spacing: pinDotSpacing,
                              ),
                              
                              // Error Message
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: isVerySmallScreen ? 8 : AppConstants.paddingMedium,
                                  ),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: subtitleFontSize,
                                    ),
                                  ),
                                ),
                              
                              SizedBox(height: topPadding / 2),
                              
                              // Lupa PIN Button
                              TextButton(
                                onPressed: _handleForgotPin,
                                child: Text(
                                  'Lupa PIN?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: subtitleFontSize,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white70,
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: topPadding / 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Number Pad
                  _buildNumberPad(
                    buttonSize: numberButtonSize,
                    fontSize: numberFontSize,
                    verticalPadding: numberPadVerticalPadding,
                    horizontalPadding: numberPadHorizontalPadding,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Responsive helper methods
  double _getIconSize(double screenHeight, double screenWidth) {
    if (screenHeight < 500) return 30;
    if (screenHeight < 600) return 36;
    if (screenHeight < 750) return 42;
    return 50;
  }

  double _getTitleFontSize(double screenHeight) {
    if (screenHeight < 500) return 20;
    if (screenHeight < 600) return 22;
    if (screenHeight < 750) return 26;
    return 30;
  }

  double _getSubtitleFontSize(double screenHeight) {
    if (screenHeight < 500) return 12;
    if (screenHeight < 600) return 13;
    if (screenHeight < 750) return 14;
    return 15;
  }

  double _getTopPadding(double screenHeight) {
    if (screenHeight < 500) return 8;
    if (screenHeight < 600) return 12;
    if (screenHeight < 750) return 20;
    return 32;
  }

  double _getSectionSpacing(double screenHeight) {
    if (screenHeight < 500) return 12;
    if (screenHeight < 600) return 16;
    if (screenHeight < 750) return 20;
    return 28;
  }

  double _getNumberButtonSize(double screenHeight, double screenWidth) {
    // Base on both height and width
    final heightBased = screenHeight < 500 ? 48.0 : 
                        screenHeight < 600 ? 54.0 : 
                        screenHeight < 750 ? 62.0 : 72.0;
    
    // Also consider width (for narrow phones)
    final widthBased = (screenWidth - 80) / 4; // 4 = 3 buttons + spacing
    
    return heightBased.clamp(44.0, widthBased.clamp(44.0, 80.0));
  }

  double _getNumberFontSize(double screenHeight) {
    if (screenHeight < 500) return 22;
    if (screenHeight < 600) return 26;
    if (screenHeight < 750) return 30;
    return 36;
  }

  double _getNumberPadVerticalPadding(double screenHeight) {
    if (screenHeight < 500) return 4;
    if (screenHeight < 600) return 6;
    if (screenHeight < 750) return 8;
    return 10;
  }

  double _getNumberPadHorizontalPadding(double screenWidth) {
    if (screenWidth < 320) return 12;
    if (screenWidth < 360) return 16;
    return AppConstants.paddingLarge;
  }

  double _getPinDotSize(double screenHeight) {
    if (screenHeight < 500) return 12;
    if (screenHeight < 600) return 14;
    if (screenHeight < 750) return 15;
    return 16;
  }

  double _getPinDotSpacing(double screenWidth) {
    if (screenWidth < 320) return 6;
    if (screenWidth < 360) return 7;
    return 8;
  }

  double _getNumberPadHeight(double screenHeight, double buttonSize, double verticalPadding) {
    // 4 rows of buttons + padding + container padding
    return (buttonSize * 4) + (verticalPadding * 8) + 24;
  }

  Widget _buildPinDots({
    required double dotSize,
    required double spacing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < _pin.length
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad({
    required double buttonSize,
    required double fontSize,
    required double verticalPadding,
    required double horizontalPadding,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: verticalPadding,
            bottom: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumberRow(
                [1, 2, 3],
                buttonSize: buttonSize,
                fontSize: fontSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildNumberRow(
                [4, 5, 6],
                buttonSize: buttonSize,
                fontSize: fontSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildNumberRow(
                [7, 8, 9],
                buttonSize: buttonSize,
                fontSize: fontSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildNumberRow(
                [null, 0, -1], // -1 for backspace
                buttonSize: buttonSize,
                fontSize: fontSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(
    List<int?> numbers, {
    required double buttonSize,
    required double fontSize,
    required double verticalPadding,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((number) {
          if (number == null) {
            return SizedBox(width: buttonSize, height: buttonSize);
          }
          if (number == -1) {
            // Backspace button
            return _buildBackspaceButton(
              buttonSize: buttonSize,
              iconSize: fontSize * 0.7,
            );
          }
          return _buildNumberButton(
            number.toString(),
            buttonSize: buttonSize,
            fontSize: fontSize,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberButton(
    String number, {
    required double buttonSize,
    required double fontSize,
  }) {
    return InkWell(
      onTap: () => _addPinDigit(number),
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppConstants.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton({
    required double buttonSize,
    required double iconSize,
  }) {
    return InkWell(
      onTap: _removePinDigit,
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: iconSize,
            color: AppConstants.primaryOrange,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../home/main_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  String _errorMessage = '';

  void _addPinDigit(String digit) {
    setState(() {
      _errorMessage = '';
      if (!_isConfirming) {
        if (_pin.length < 6) {
          _pin.add(digit);
          if (_pin.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin.add(digit);
          if (_confirmPin.length == 6) {
            _verifyPin();
          }
        }
      }
    });
  }

  void _removePinDigit() {
    setState(() {
      _errorMessage = '';
      if (!_isConfirming && _pin.isNotEmpty) {
        _pin.removeLast();
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin.removeLast();
        if (_confirmPin.isEmpty) {
          _isConfirming = false;
        }
      }
    });
  }

  void _verifyPin() async {
    // Beri sedikit jeda agar UI sempat merender titik ke-6
    await Future.delayed(const Duration(milliseconds: 300));

    if (_pin.join() == _confirmPin.join()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Ambil nama dari Firebase jika ada
      final firebaseUser = FirebaseAuth.instance.currentUser;
      await firebaseUser?.reload(); // Memaksa pembaruan data dari server
      final updatedUser = FirebaseAuth.instance.currentUser;

      String userName = 'Pengguna';
      if (updatedUser != null) {
        if (updatedUser.displayName != null && updatedUser.displayName!.isNotEmpty) {
          userName = updatedUser.displayName!;
        } else if (updatedUser.email != null && updatedUser.email!.isNotEmpty) {
          // Jika nama kosong (misal akun lama), gunakan bagian depan email
          userName = updatedUser.email!.split('@').first;
        }
      }

      // Create user with the PIN and Firebase Name
      final user = UserModel(
        name: userName,
        photoPath: updatedUser?.photoURL,
        pin: _pin.join(),
      );

      await userProvider.createUser(user);
      await userProvider.setPinSet(true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'PIN tidak cocok, coba lagi';
        _isConfirming = false;
        _confirmPin.clear();
      });
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup PIN'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            // Responsive breakpoints
            final isVerySmallScreen = screenHeight < 450;
            final isSmallScreen = screenHeight >= 450 && screenHeight < 550;
            final isMediumScreen = screenHeight >= 550 && screenHeight < 700;

            // Calculate responsive sizes
            final iconSize = _getIconSize(screenHeight);
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
                        minHeight: constraints.maxHeight -
                            _getNumberPadHeight(numberButtonSize, numberPadVerticalPadding),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 12 : AppConstants.paddingLarge,
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
                                color: AppConstants.primaryOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                size: iconSize,
                                color: AppConstants.primaryOrange,
                              ),
                            ),

                            SizedBox(height: sectionSpacing),

                            // Title
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isConfirming ? 'Konfirmasi PIN' : 'Buat PIN',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontSize: titleFontSize,
                                    ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 4 : 8),

                            // Subtitle
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVerySmallScreen ? 8 : 16,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isConfirming
                                      ? 'Masukkan PIN yang sama untuk konfirmasi'
                                      : 'Buat 6 digit PIN untuk keamanan akun Anda',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.textSecondary,
                                        fontSize: subtitleFontSize,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.errorColor,
                                        fontSize: subtitleFontSize,
                                      ),
                                ),
                              ),

                            SizedBox(height: topPadding),
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
    );
  }

  // Responsive helper methods
  double _getIconSize(double screenHeight) {
    if (screenHeight < 450) return 28;
    if (screenHeight < 550) return 34;
    if (screenHeight < 700) return 42;
    return 50;
  }

  double _getTitleFontSize(double screenHeight) {
    if (screenHeight < 450) return 18;
    if (screenHeight < 550) return 22;
    if (screenHeight < 700) return 26;
    return 30;
  }

  double _getSubtitleFontSize(double screenHeight) {
    if (screenHeight < 450) return 11;
    if (screenHeight < 550) return 12;
    if (screenHeight < 700) return 14;
    return 15;
  }

  double _getTopPadding(double screenHeight) {
    if (screenHeight < 450) return 4;
    if (screenHeight < 550) return 8;
    if (screenHeight < 700) return 16;
    return 24;
  }

  double _getSectionSpacing(double screenHeight) {
    if (screenHeight < 450) return 10;
    if (screenHeight < 550) return 14;
    if (screenHeight < 700) return 20;
    return 28;
  }

  double _getNumberButtonSize(double screenHeight, double screenWidth) {
    // Base on both height and width
    final heightBased = screenHeight < 450
        ? 44.0
        : screenHeight < 550
            ? 52.0
            : screenHeight < 700
                ? 60.0
                : 72.0;

    // Also consider width (for narrow phones)
    final widthBased = (screenWidth - 80) / 4; // 4 = 3 buttons + spacing

    return heightBased.clamp(40.0, widthBased.clamp(40.0, 80.0));
  }

  double _getNumberFontSize(double screenHeight) {
    if (screenHeight < 450) return 20;
    if (screenHeight < 550) return 24;
    if (screenHeight < 700) return 28;
    return 36;
  }

  double _getNumberPadVerticalPadding(double screenHeight) {
    if (screenHeight < 450) return 3;
    if (screenHeight < 550) return 5;
    if (screenHeight < 700) return 7;
    return 10;
  }

  double _getNumberPadHorizontalPadding(double screenWidth) {
    if (screenWidth < 300) return 8;
    if (screenWidth < 340) return 12;
    if (screenWidth < 380) return 16;
    return AppConstants.paddingLarge;
  }

  double _getPinDotSize(double screenHeight) {
    if (screenHeight < 450) return 10;
    if (screenHeight < 550) return 12;
    if (screenHeight < 700) return 14;
    return 16;
  }

  double _getPinDotSpacing(double screenWidth) {
    if (screenWidth < 300) return 4;
    if (screenWidth < 340) return 5;
    if (screenWidth < 380) return 6;
    return 8;
  }

  double _getNumberPadHeight(double buttonSize, double verticalPadding) {
    // 4 rows of buttons + padding + container padding
    return (buttonSize * 4) + (verticalPadding * 10) + 20;
  }

  Widget _buildPinDots({
    required double dotSize,
    required double spacing,
  }) {
    final currentPin = _isConfirming ? _confirmPin : _pin;
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
              color: index < currentPin.length
                  ? AppConstants.primaryOrange
                  : AppConstants.dividerColor,
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
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
          color: number == '0' && _confirmPin.isEmpty
              ? AppConstants.primaryOrange.withOpacity(0.1)
              : null,
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
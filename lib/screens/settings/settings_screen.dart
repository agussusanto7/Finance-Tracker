import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_provider.dart';
import '../budget/budget_screen.dart';
import '../gallery/gallery_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SingleChildScrollView(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;

            if (user == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 64,
                        color: AppConstants.textSecondary,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'Data profil belum diisi',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildProfileHeader(context, userProvider),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildSettingsSection(context, userProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user!;
    final hasPhoto = user.photoPath != null;
    final photoFile = hasPhoto ? File(user.photoPath!) : null;
    final photoExists = photoFile?.existsSync() ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: AppTheme.appBarGradient,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: photoExists
                    ? FileImage(photoFile!)
                    : const AssetImage('assets/images/profil.png'),
                child: !photoExists
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryOrange,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    color: AppConstants.primaryOrange,
                    onPressed: () =>
                        _showPhotoSourceDialog(context, userProvider),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final user = userProvider.user!;

    return Column(
      children: [
        _buildSettingCard(
          context,
          title: 'Profil',
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nama'),
              subtitle: Text(user.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditNameDialog(context, userProvider),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Ubah PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePinDialog(context, userProvider),
            ),
          ],
        ),
        _buildSettingCard(
          context,
          title: 'Preferensi',
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.visibility_off),
              title: const Text('Sembunyikan Saldo'),
              subtitle: const Text('Sembunyikan nominal saldo di dashboard'),
              value: user.balanceHidden,
              onChanged: (value) {
                userProvider.toggleBalanceHidden();
              },
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Autentikasi Biometrik'),
              subtitle: const Text('Gunakan sidik jari untuk login'),
              value: user.biometricEnabled,
              onChanged: (value) {
                userProvider.toggleBiometric(value);
              },
            ),
          ],
        ),
        _buildSettingCard(
          context,
          title: 'Budget & Kategori',
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Kelola Budget'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kelola Kategori'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to category management screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri Bukti Transaksi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GalleryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        _buildSettingCard(
          context,
          title: 'Lainnya',
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              subtitle: Text('Versi ${AppConstants.appVersion}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppConstants.errorColor),
              title: const Text(
                'Keluar',
                style: TextStyle(color: AppConstants.errorColor),
              ),
              onTap: () {
                _showLogoutDialog(context, userProvider);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController(
      text: userProvider.user?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama Anda',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }

              final updatedUser = userProvider.user!.copyWith(
                name: controller.text.trim(),
              );
              userProvider.updateUser(updatedUser);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nama berhasil diubah')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourceDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Foto Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _updatePhoto(context, ImageSource.camera, userProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _updatePhoto(context, ImageSource.gallery, userProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePhoto(
    BuildContext context,
    ImageSource source,
    UserProvider userProvider,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      final updatedUser = userProvider.user!.copyWith(
        photoPath: pickedFile.path,
      );
      await userProvider.updateUser(updatedUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diubah')),
        );
      }
    }
  }

  void _showChangePinDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ChangePinDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 48,
        color: AppConstants.primaryOrange,
      ),
      children: [
        const Text('Aplikasi manajemen keuangan pribadi dengan UI modern'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.logout();
              Navigator.pop(context);
              // Navigate back to splash or login screen
              Navigator.pushReplacementNamed(context, '/splash');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final List<String> _oldPin = [];
  final List<String> _newPin = [];
  final List<String> _confirmPin = [];
  int _step = 0; // 0: enter old, 1: enter new, 2: confirm new
  String _errorMessage = '';

  void _addDigit(String digit) {
    setState(() {
      _errorMessage = '';
      if (_step == 0) {
        if (_oldPin.length < 6) {
          _oldPin.add(digit);
          if (_oldPin.length == 6) {
            _verifyOldPin();
          }
        }
      } else if (_step == 1) {
        if (_newPin.length < 6) {
          _newPin.add(digit);
          if (_newPin.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _step = 2;
              });
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin.add(digit);
          if (_confirmPin.length == 6) {
            _verifyAndSavePin();
          }
        }
      }
    });
  }

  void _removeDigit() {
    setState(() {
      _errorMessage = '';
      if (_step == 0 && _oldPin.isNotEmpty) {
        _oldPin.removeLast();
      } else if (_step == 1 && _newPin.isNotEmpty) {
        _newPin.removeLast();
      } else if (_step == 2 && _confirmPin.isNotEmpty) {
        _confirmPin.removeLast();
      }
    });
  }

  Future<void> _verifyOldPin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final oldPinEntered = _oldPin.join();

    if (userProvider.user?.pin == oldPinEntered) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _step = 1;
        });
      });
    } else {
      setState(() {
        _errorMessage = 'PIN lama salah';
        _oldPin.clear();
      });
    }
  }

  Future<void> _verifyAndSavePin() async {
    final newPin = _newPin.join();
    final confirmPin = _confirmPin.join();

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = 'PIN baru tidak cocok';
        _confirmPin.clear();
        _step = 1;
      });
      return;
    }

    if (newPin == _oldPin.join()) {
      setState(() {
        _errorMessage = 'PIN baru tidak boleh sama dengan PIN lama';
        _newPin.clear();
        _confirmPin.clear();
        _step = 1;
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updatePin(newPin);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String title;
    String subtitle;
    List<String> currentPin;

    switch (_step) {
      case 0:
        title = 'Masukkan PIN Lama';
        subtitle = 'Masukkan PIN Anda saat ini untuk verifikasi';
        currentPin = _oldPin;
        break;
      case 1:
        title = 'Masukkan PIN Baru';
        subtitle = 'Buat 6 digit PIN baru';
        currentPin = _newPin;
        break;
      default:
        title = 'Konfirmasi PIN Baru';
        subtitle = 'Masukkan kembali PIN baru Anda';
        currentPin = _confirmPin;
    }

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Ubah PIN'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.06),
                  _buildPinDots(currentPin),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.03),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(height: screenWidth * 0.06),
                  _buildNumberPad(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(List<String> pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < pin.length
                  ? AppConstants.primaryOrange
                  : AppConstants.dividerColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          _buildNumberRow([1, 2, 3]),
          _buildNumberRow([4, 5, 6]),
          _buildNumberRow([7, 8, 9]),
          _buildNumberRow([null, 0, null]),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<int?> numbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingSmall,
        horizontal: AppConstants.paddingLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((number) {
          if (number == null) {
            return _buildDeleteButton();
          }
          return _buildNumberButton(number.toString());
        }).toList(),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _addDigit(number),
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Text(
            number,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppConstants.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final currentPinLength = _step == 0
        ? _oldPin.length
        : _step == 1
        ? _newPin.length
        : _confirmPin.length;

    return InkWell(
      onTap: currentPinLength > 0 ? _removeDigit : null,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Icon(
            Icons.backspace,
            color: currentPinLength > 0
                ? AppConstants.textSecondary
                : AppConstants.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

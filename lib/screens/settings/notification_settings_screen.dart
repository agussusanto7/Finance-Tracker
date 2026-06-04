import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isDailyReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // 8:00 PM default
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', _isDailyReminderEnabled);
    await prefs.setInt('daily_reminder_hour', _reminderTime.hour);
    await prefs.setInt('daily_reminder_minute', _reminderTime.minute);

    if (_isDailyReminderEnabled) {
      await NotificationService().scheduleDailyReminder(
        id: 0,
        title: 'Pengingat Harian',
        body: 'Jangan lupa catat pengeluaran dan pemasukan Anda hari ini!',
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await NotificationService().cancelNotification(0);
    }
  }

  Future<void> _toggleDailyReminder(bool value) async {
    if (value) {
      // Request permission before enabling
      final granted = await NotificationService().requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin notifikasi ditolak. Harap izinkan melalui pengaturan perangkat.')),
        );
        return;
      }
    }
    
    setState(() {
      _isDailyReminderEnabled = value;
    });
    await _saveSettings();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveSettings();
    }
  }

  Future<void> _testNotification() async {
    final granted = await NotificationService().requestPermissions();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin notifikasi ditolak.')),
      );
      return;
    }

    await NotificationService().showInstantNotification(
      id: 99,
      title: 'Finance Tracker',
      body: 'Ini adalah contoh notifikasi pengingat transaksi Anda.',
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi uji coba terkirim! Silakan cek panel notifikasi Anda.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final provider = Provider.of<ThemeProvider>(context);
    final isDarkMode = provider.isDarkMode;
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E2E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Transaksi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pengingat Harian', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Ingatkan saya untuk mencatat keuangan setiap hari'),
                  value: _isDailyReminderEnabled,
                  onChanged: _toggleDailyReminder,
                  activeTrackColor: AppConstants.primaryColor.withValues(alpha: 0.5),
                  activeThumbColor: AppConstants.primaryColor,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: AppConstants.primaryColor),
                  ),
                ),
                if (_isDailyReminderEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Waktu Pengingat'),
                    subtitle: Text('Diatur pada ${_reminderTime.format(context)}'),
                    trailing: const Icon(Icons.access_time_rounded),
                    onTap: () => _selectTime(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: AppConstants.successColor),
              ),
              title: const Text('Uji Coba Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Kirim notifikasi sekarang untuk memastikan fitur berjalan'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _testNotification,
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            'Tips: Gunakan fitur pengingat ini agar Anda tidak lupa mencatat pengeluaran harian atau tagihan rutin setiap bulannya.',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

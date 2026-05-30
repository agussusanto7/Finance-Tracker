import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../dashboard/dashboard_screen.dart';
import '../transaction/transaction_list_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../calculator/calculator_screen.dart'; // Import halaman kalkulator

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionListScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          // Desktop: Sidebar
          return _buildDesktopLayout(context);
        } else if (constraints.maxWidth >= 600) {
          // Tablet: Navigation Rail
          return _buildTabletLayout(context);
        } else {
          // Mobile: Bottom Navigation
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: cs.surface,
            selectedIconTheme: IconThemeData(color: AppConstants.primaryColor),
            unselectedIconTheme: IconThemeData(color: textSecondary),
            selectedLabelTextStyle: TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
            leading: Column(
              children: [
                const SizedBox(height: 16),
                _buildFab(context),
                const SizedBox(height: 24),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_rounded),
                label: Text('Beranda'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_rounded),
                label: Text('Transaksi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pie_chart_rounded),
                label: Text('Statistik'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_rounded),
                label: Text('Pengaturan'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1, color: cs.onSurface.withOpacity(0.1)),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: cs.surface,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'FinanceTracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalculatorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      label: const Text(
                        'Kalkulator',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSidebarItem(context, Icons.home_rounded, 'Beranda', 0),
                _buildSidebarItem(context, Icons.receipt_long_rounded, 'Transaksi', 1),
                _buildSidebarItem(context, Icons.pie_chart_rounded, 'Statistik', 2),
                _buildSidebarItem(context, Icons.settings_rounded, 'Pengaturan', 3),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: cs.onSurface.withOpacity(0.1)),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final cs = Theme.of(context).colorScheme;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConstants.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppConstants.primaryColor : textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppConstants.primaryColor : textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalculatorScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.calculate, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildNavItem(context, Icons.home_rounded, 'Beranda', 0)),
              Expanded(child: _buildNavItem(context, Icons.receipt_long_rounded, 'Transaksi', 1)),
              const SizedBox(width: 72), // Increased Placeholder for FAB
              Expanded(child: _buildNavItem(context, Icons.pie_chart_rounded, 'Statistik', 2)),
              Expanded(child: _buildNavItem(context, Icons.settings_rounded, 'Pengaturan', 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final cs = Theme.of(context).colorScheme;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppConstants.primaryColor : textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppConstants.primaryColor : textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
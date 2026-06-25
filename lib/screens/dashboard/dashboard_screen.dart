import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../chat/chat_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../budget/budget_screen.dart';
import '../home/main_screen.dart';
import '../education/education_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Latar belakang sedikit diperhalus agar kontras dengan kartu lebih baik
    final bgColor = cs.surface == const Color(0xFF1E1E2E)
        ? const Color(0xFF121218)
        : const Color(0xFFF8F9FA); 

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
        },
        color: AppConstants.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), // Agar refresh indicator jalan
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Padding dioptimalkan
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildConsultationBanner(context),
                    const SizedBox(height: 24),
                    _buildMonthlyChart(context),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(context),
                    const SizedBox(height: 20), // Ekstra padding bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final userName = user?.name ?? 'Pengguna';
        final firstName = userName.split(' ').first;
        
        final hasPhoto = user?.photoPath != null && user!.photoPath!.isNotEmpty;
        final isNetworkPhoto = hasPhoto && user!.photoPath!.startsWith('http');
        final photoFile = hasPhoto && !isNetworkPhoto ? File(user!.photoPath!) : null;
        final photoExists = isNetworkPhoto || (photoFile?.existsSync() ?? false);

        ImageProvider? getProfileImage() {
          if (isNetworkPhoto) return NetworkImage(user!.photoPath!);
          if (photoExists && photoFile != null) return FileImage(photoFile);
          return null;
        }
        
        return SliverAppBar(
          toolbarHeight: 75, 
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95), // Efek semi transparan
          elevation: 0,
          centerTitle: false,
          titleSpacing: 24,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $firstName! 👋',
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6),
                  fontSize: isSmallScreen ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'FinanceTracker',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(initialIndex: 3),
                    ),
                    (route) => false,
                  );
                },
                child: Hero(
                  tag: 'profile_avatar', // Transisi modern jika berpindah halaman
                  child: Container(
                    padding: const EdgeInsets.all(2), // Border ring
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.15),
                      backgroundImage: getProfileImage(),
                      child: !photoExists
                          ? Text(
                              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'P',
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final transactionProvider = Provider.of<TransactionProvider>(context);
        final balanceHidden = userProvider.user?.balanceHidden ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.gradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(28), // Lebih membulat
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 12), // Shadow lebih "melayang"
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Saldo',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            balanceHidden
                                ? 'Rp ••••••••'
                                : CurrencyFormatter.formatCurrency(
                                    transactionProvider.totalBalance),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width < 360 ? 28 : 36,
                              fontWeight: FontWeight.w800, // Lebih tebal
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        userProvider.toggleBalanceHidden();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ), // Sentuhan Glassmorphism
                        ),
                        child: Icon(
                          balanceHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ), // Sentuhan Glassmorphism bagian dalam
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceItem(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Pemasukan',
                      color: AppConstants.successColor,
                      onGetAmount: () =>
                          transactionProvider.getTotalIncomeByMonth(DateTime.now()),
                      balanceHidden: balanceHidden,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    _buildBalanceItem(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Pengeluaran',
                      color: AppConstants.errorColor,
                      onGetAmount: () =>
                          transactionProvider.getTotalExpenseByMonth(DateTime.now()),
                      balanceHidden: balanceHidden,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required Color color,
    required Future<double> Function() onGetAmount,
    required bool balanceHidden,
  }) {
    return FutureBuilder<double>(
      future: onGetAmount(),
      builder: (context, snapshot) {
        final amount = snapshot.data ?? 0.0;
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        balanceHidden ? '• • •' : CurrencyFormatter.formatCompact(amount),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width < 360 ? 15 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow sangat halus
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  color: AppConstants.successColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: TransactionType.income,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  color: AppConstants.errorColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: TransactionType.expense,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  color: AppConstants.primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BudgetScreen()),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildQuickActionButton(
                  context: context,
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Edukasi',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EducationScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        highlightColor: color.withOpacity(0.1),
        splashColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width < 360 ? 56 : 64,
                height: MediaQuery.of(context).size.width < 360 ? 56 : 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12), // Background warna lebih soft
                  borderRadius: BorderRadius.circular(20), // Ikon membulat kekinian
                ),
                child: Icon(icon, color: color, size: MediaQuery.of(context).size.width < 360 ? 28 : 32),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 360 ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;
    final divider = cs.onSurface.withOpacity(0.08);

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ringkasan Bulan Ini',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Bulan ini',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: MediaQuery.of(context).size.width < 360 ? 140 : 160,
                child: FutureBuilder<List<double>>(
                  future: Future.wait([
                    provider.getTotalIncomeByMonth(DateTime.now()),
                    provider.getTotalExpenseByMonth(DateTime.now()),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final income = snapshot.data![0];
                      final expense = snapshot.data![1];
                      final total = income + expense;

                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections: total == 0
                                    ? [
                                        PieChartSectionData(
                                          value: 1,
                                          color: divider,
                                          radius: 35,
                                          showTitle: false,
                                        ),
                                      ]
                                    : [
                                        if (income > 0)
                                          PieChartSectionData(
                                            value: income,
                                            color: AppConstants.successColor,
                                            radius: 28, // Radius disesuaikan
                                            showTitle: false,
                                          ),
                                        if (expense > 0)
                                          PieChartSectionData(
                                            value: expense,
                                            color: AppConstants.errorColor,
                                            radius: 28, // Radius disesuaikan
                                            showTitle: false,
                                          ),
                                      ],
                                sectionsSpace: 2, // Tambah ruang antar bagian chart
                                centerSpaceRadius: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildChartLegend(
                                  context: context,
                                  color: AppConstants.successColor,
                                  label: 'Pemasukan',
                                  value: CurrencyFormatter.formatCompact(income),
                                  percentage: total > 0
                                      ? '${((income / total) * 100).round()}%'
                                      : '0%',
                                ),
                                const SizedBox(height: 12),
                                _buildChartLegend(
                                  context: context,
                                  color: AppConstants.errorColor,
                                  label: 'Pengeluaran',
                                  value: CurrencyFormatter.formatCompact(expense),
                                  percentage: total > 0
                                      ? '${((expense / total) * 100).round()}%'
                                      : '0%',
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: divider),
                                const SizedBox(height: 12),
                                _buildChartLegend(
                                  context: context,
                                  color: AppConstants.primaryColor,
                                  label: 'Sisa',
                                  value: CurrencyFormatter.formatCompact(
                                    income - expense,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppConstants.primaryColor,
                    ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartLegend({
    required BuildContext context,
    required Color color,
    required String label,
    required String value,
    String? percentage,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle, // Dot legend dibuat bulat
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (percentage != null)
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 360 ? 12 : 14,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(initialIndex: 1),
                        ),
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.05), // Sedikit latar belakang pada tombol
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<TransactionModel>>(
                future: provider.getRecentTransactions(5),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppConstants.primaryColor),
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: textSecondary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: textSecondary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada transaksi',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: AppConstants.errorColor),
                        ),
                      ),
                    );
                  }

                  final transactions = snapshot.data ?? [];
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Divider(
                        color: cs.onSurface.withOpacity(0.06),
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionItem(context, transaction);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    final isExpense = transaction.type == TransactionType.expense;
    final amount = transaction.amount;
    final category = transaction.category;
    final date = transaction.date;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isExpense
                      ? AppConstants.errorColor
                      : AppConstants.successColor)
                  .withOpacity(0.12), // Background warna lebih solid tipis
              borderRadius: BorderRadius.circular(16), // Rounded modern
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isExpense
                  ? AppConstants.errorColor
                  : AppConstants.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatRelativeDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${isExpense ? '-' : '+'}${CurrencyFormatter.formatCurrency(amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800, // Teks nominal dipertegas
                  color: isExpense
                      ? AppConstants.errorColor
                      : AppConstants.successColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Melengkung lebih bagus
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DB0E6).withOpacity(0.3), // Cahaya kebiruan (Glow Effect)
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Gradient Biru yang cerah dan modern
              gradient: const LinearGradient(
                colors: [Color(0xFF4DB0E6), Color(0xFF3291C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // Ilustrasi puzzle dan orang
                Hero( // Sedikit efek hero untuk aset gambar jika ada di screen selanjutnya
                  tag: 'consultation_image',
                  child: Image.asset(
                    'assets/images/konsultasi.png',
                    width: MediaQuery.of(context).size.width < 360 ? 90 : 110,
                    height: MediaQuery.of(context).size.width < 360 ? 90 : 110,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                // Konten Teks & Tombol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ingin Konsultasi?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Diubah menjadi putih agar lebih menyatu dengan gradient
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bingung dengan keuangan kamu sekarang? Konsultasi aja!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9), // Sedikit transparan untuk hierarki visual
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E), // Tombol gelap modern
                          borderRadius: BorderRadius.circular(14), // Rounded button
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Konsultasi',
                          style: TextStyle(
                            color: Color(0xFF4DB0E6), // Teks tombol tetap warna tema
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
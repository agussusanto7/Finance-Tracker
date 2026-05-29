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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = cs.surface == const Color(0xFF1E1E2E)
        ? const Color(0xFF121218)
        : const Color(0xFFF4F5F9);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(context),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildConsultationBanner(context),
                  const SizedBox(height: 20),
                  _buildMonthlyChart(context),
                  const SizedBox(height: 20),
                  _buildRecentTransactions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.user?.name ?? 'Pengguna';
        // Ambil nama depan saja agar tidak terlalu panjang
        final firstName = userName.split(' ').first;
        
        return SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, $firstName! 👋',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FinanceTracker',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.gradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            balanceHidden
                                ? 'Rp ••••••••'
                                : CurrencyFormatter.formatCurrency(
                                    transactionProvider.totalBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      userProvider.toggleBalanceHidden();
                    },
                    icon: Icon(
                      balanceHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
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
                      color: Colors.white.withOpacity(0.2),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        balanceHidden ? '• • •' : CurrencyFormatter.formatCompact(amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
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
              _buildQuickActionButton(
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
              _buildQuickActionButton(
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.55);
    final divider = cs.onSurface.withOpacity(0.12);

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
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
                                            radius: 25,
                                            title:
                                                '${((income / total) * 100).toInt()}%',
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            titlePositionPercentageOffset: 0.6,
                                          ),
                                        if (expense > 0)
                                          PieChartSectionData(
                                            value: expense,
                                            color: AppConstants.errorColor,
                                            radius: 25,
                                            title:
                                                '${((expense / total) * 100).toInt()}%',
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            titlePositionPercentageOffset: 0.6,
                                          ),
                                      ],
                                sectionsSpace: total == 0 ? 0 : 2,
                                centerSpaceRadius: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                      ? '${((income / total) * 100).toInt()}%'
                                      : '0%',
                                ),
                                const SizedBox(height: 12),
                                _buildChartLegend(
                                  context: context,
                                  color: AppConstants.errorColor,
                                  label: 'Pengeluaran',
                                  value: CurrencyFormatter.formatCompact(expense),
                                  percentage: total > 0
                                      ? '${((expense / total) * 100).toInt()}%'
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
                                  percentage: total > 0
                                      ? '${(((income - expense) / total) * 100).toInt()}%'
                                      : '0%',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (percentage != null)
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
    final divider = cs.onSurface.withOpacity(0.12);

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    'Transaksi Terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<TransactionModel>>(
                future: provider.getRecentTransactions(5),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
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
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada transaksi',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
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
                    separatorBuilder: (context, index) => Divider(
                      color: divider,
                      height: 1,
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isExpense
                      ? AppConstants.errorColor
                      : AppConstants.successColor)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatRelativeDate(date),
                  style: TextStyle(
                    fontSize: 11,
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4DB0E6), // Biru cerah sesuai referensi
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Ilustrasi puzzle dan orang
            Image.asset(
              'assets/images/konsultasi.png',
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            // Konten Teks & Tombol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingin Konsultasi?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E), // Teks gelap
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bingung dengan Keuangan kamu sekarang? Konsultasi aja!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF333333),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A), // Tombol gelap
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Konsultasi',
                      style: TextStyle(
                        color: Color(0xFF4DB0E6), // Teks tombol berwarna biru cerah
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
    );
  }
}
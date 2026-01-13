import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildQuickActions(),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildMonthlyChart(),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.15,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: AppTheme.appBarGradient,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final transactionProvider = Provider.of<TransactionProvider>(context);
        final balanceHidden = userProvider.user?.balanceHidden ?? false;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;

        return Container(
          width: double.infinity,
          decoration: AppTheme.cardGradient,
          padding: EdgeInsets.all(isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Total Saldo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.045,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      userProvider.toggleBalanceHidden();
                    },
                    icon: Icon(
                      balanceHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  balanceHidden
                      ? 'Rp ***'
                      : CurrencyFormatter.formatCurrency(
                          transactionProvider.totalBalance),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? screenWidth * 0.065 : screenWidth * 0.08,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: screenWidth * 0.04,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            // Use Wrap for responsive layout on small screens
            Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenWidth * 0.02,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.arrow_downward,
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
                  icon: Icons.arrow_upward,
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
                  icon: Icons.account_balance_wallet,
                  label: 'Budget',
                  color: AppConstants.infoColor,
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
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? screenWidth * 0.01 : screenWidth * 0.015),
        child: Column(
          children: [
            Container(
              width: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.13,
              height: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.13,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? screenWidth * 0.07 : screenWidth * 0.06),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: isSmallScreen ? screenWidth * 0.028 : screenWidth * 0.03,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenHeight < 600;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Bulan Ini',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                SizedBox(
                  height: isSmallScreen ? screenHeight * 0.20 : screenHeight * 0.25,
                  child: FutureBuilder(
                    future: Future.wait([
                      provider.getTotalIncomeByMonth(DateTime.now()),
                      provider.getTotalExpenseByMonth(DateTime.now()),
                    ]),
                    builder: (context, AsyncSnapshot<List<double>> snapshot) {
                      if (snapshot.hasData) {
                        final income = snapshot.data![0];
                        final expense = snapshot.data![1];

                        return PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: income,
                                title: 'Pemasukan\n${CurrencyFormatter.formatCompact(income)}',
                                color: AppConstants.successColor,
                                radius: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.18,
                                titleStyle: TextStyle(
                                  fontSize: isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: expense,
                                title: 'Pengeluaran\n${CurrencyFormatter.formatCompact(expense)}',
                                color: AppConstants.errorColor,
                                radius: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.18,
                                titleStyle: TextStyle(
                                  fontSize: isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: isSmallScreen ? screenWidth * 0.12 : screenWidth * 0.09,
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Transaksi Terbaru',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to transaction list
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                FutureBuilder(
                  future: provider.getRecentTransactions(5),
                  builder: (context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingLarge),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.08),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: screenWidth * 0.15,
                                color: AppConstants.textSecondary,
                              ),
                              SizedBox(height: screenWidth * 0.04),
                              Text(
                                'Belum ada transaksi',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                          color: AppConstants.textSecondary,
                                          fontSize: screenWidth * 0.035,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: AppConstants.errorColor,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      );

                    }

                    final transactions = snapshot.data ?? [];
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionItem(transaction);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final amount = transaction.amount;
    final category = transaction.category;
    final date = transaction.date;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Container(
        width: screenWidth * 0.11,
        height: screenWidth * 0.11,
        decoration: BoxDecoration(
          color: isExpense
              ? AppConstants.errorColor.withOpacity(0.1)
              : AppConstants.successColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
          color: isExpense
              ? AppConstants.errorColor
              : AppConstants.successColor,
          size: screenWidth * 0.05,
        ),
      ),
      title: Text(
        category,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: screenWidth * 0.04,
        ),
      ),
      subtitle: Text(
        DateFormatter.formatRelativeDate(date),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: screenWidth * 0.03,
        ),
      ),
      trailing: FittedBox(
        child: Text(
          '${isExpense ? '-' : '+'}${CurrencyFormatter.formatCurrency(amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isExpense
                    ? AppConstants.errorColor
                    : AppConstants.successColor,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
        ),
      ),
    );
  }
}

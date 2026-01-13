import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Minggu Ini', 'Bulan Ini', 'Tahun Ini'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik & Laporan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildSummaryCards(),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildIncomeExpenseChart(),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildCategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppConstants.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return FutureBuilder(
          future: _getPeriodData(provider),
          builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final income = snapshot.data?['income'] ?? 0.0;
            final expense = snapshot.data?['expense'] ?? 0.0;
            final balance = income - expense;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Pemasukan',
                        amount: income,
                        color: AppConstants.successColor,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Pengeluaran',
                        amount: expense,
                        color: AppConstants.errorColor,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildSummaryCard(
                  title: 'Saldo',
                  amount: balance,
                  color: AppConstants.infoColor,
                  icon: Icons.account_balance_wallet,
                  isFullWidth: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth * 0.09,
                height: screenWidth * 0.09,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: screenWidth * 0.045),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: screenWidth * 0.032,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          FittedBox(
            child: Text(
              CurrencyFormatter.formatCurrency(amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.055,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemasukan vs Pengeluaran',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: FutureBuilder(
                    future: _getPeriodData(provider),
                    builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final income = snapshot.data?['income'] ?? 0.0;
                      final expense = snapshot.data?['expense'] ?? 0.0;
                      final screenWidth = MediaQuery.of(context).size.width;

                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (income > expense ? income : expense) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                                    child: Text(
                                      value == 0 ? 'Pemasukan' : 'Pengeluaran',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: screenWidth * 0.03,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: screenWidth * 0.14,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: screenWidth * 0.02),
                                    child: Text(
                                      CurrencyFormatter.formatCompact(value),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: screenWidth * 0.028,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: income,
                                  color: AppConstants.successColor,
                                  width: screenWidth * 0.09,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(screenWidth * 0.02),
                                    topRight: Radius.circular(screenWidth * 0.02),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: expense,
                                  color: AppConstants.errorColor,
                                  width: screenWidth * 0.09,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(screenWidth * 0.02),
                                    topRight: Radius.circular(screenWidth * 0.02),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
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

  Widget _buildCategoryBreakdown() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breakdown Pengeluaran',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                FutureBuilder(
                  future: provider.getExpensesByCategory(DateTime.now()),
                  builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingLarge),
                          child: Text('Tidak ada data pengeluaran'),
                        ),
                      );
                    }

                    final expensesByCategory = snapshot.data!;
                    final sortedCategories = expensesByCategory.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    final totalExpense = sortedCategories.fold<double>(
                      0,
                      (sum, entry) => sum + entry.value,
                    );

                    return Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: sortedCategories.asMap().entries.map((entry) {
                                final index = entry.key;
                                final category = entry.value;
                                final percentage = (category.value / totalExpense * 100);
                                final color = AppConstants.chartColors[
                                    index % AppConstants.chartColors.length];

                                return PieChartSectionData(
                                  value: category.value,
                                  title: '${percentage.toStringAsFixed(1)}%',
                                  color: color,
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        ...sortedCategories.take(5).map((entry) {
                          final percentage = (entry.value / totalExpense * 100);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingSmall,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppConstants.chartColors[
                                        sortedCategories.indexOf(entry) %
                                            AppConstants.chartColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingSmall),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Text(
                                  CurrencyFormatter.formatCurrency(entry.value),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
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

  Future<Map<String, double>> _getPeriodData(TransactionProvider provider) async {
    DateTime now = DateTime.now();

    switch (_selectedPeriod) {
      case 0: // Minggu Ini
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));

        final transactions = await provider.getTransactionsByDateRange(
          startOfWeek,
          endOfWeek,
        );

        final income = transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);

        return {'income': income, 'expense': expense};

      case 1: // Bulan Ini
        final income = await provider.getTotalIncomeByMonth(now);
        final expense = await provider.getTotalExpenseByMonth(now);

        return {'income': income, 'expense': expense};

      case 2: // Tahun Ini
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);

        final transactions = await provider.getTransactionsByDateRange(
          startOfYear,
          endOfYear,
        );

        final income = transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);

        return {'income': income, 'expense': expense};

      default:
        return {'income': 0.0, 'expense': 0.0};
    }
  }
}

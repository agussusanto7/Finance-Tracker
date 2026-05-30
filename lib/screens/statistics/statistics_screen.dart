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

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 1;
  final List<String> _periods = ['Minggu Ini', 'Bulan Ini', 'Tahun Ini'];
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _selectedPeriod,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedPeriod = _tabController.index;
          _currentDate = DateTime.now(); // reset date to now when changing tab
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Statistik',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(context),
            const SizedBox(height: 16),
            _buildDateNavigator(context),
            const SizedBox(height: 24),
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            _buildIncomeExpenseChart(context),
            const SizedBox(height: 24),
            _buildCategoryBreakdown(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String dateLabel = '';
    
    if (_selectedPeriod == 0) {
      final startOfWeek = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      dateLabel = '${DateFormatter.formatShortDate(startOfWeek)} - ${DateFormatter.formatShortDate(endOfWeek)}';
    } else if (_selectedPeriod == 1) {
      dateLabel = DateFormatter.formatMonthYear(_currentDate);
    } else {
      dateLabel = '${_currentDate.year}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: cs.onSurface),
          onPressed: () {
            setState(() {
              if (_selectedPeriod == 0) {
                _currentDate = _currentDate.subtract(const Duration(days: 7));
              } else if (_selectedPeriod == 1) {
                _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, _currentDate.day);
              } else {
                _currentDate = DateTime(_currentDate.year - 1, _currentDate.month, _currentDate.day);
              }
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _currentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDatePickerMode: _selectedPeriod == 2 ? DatePickerMode.year : DatePickerMode.day,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: cs.primary,
                            ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _currentDate) {
                  setState(() {
                    _currentDate = picked;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 20, color: cs.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: cs.onSurface),
          onPressed: () {
            setState(() {
              if (_selectedPeriod == 0) {
                _currentDate = _currentDate.add(const Duration(days: 7));
              } else if (_selectedPeriod == 1) {
                _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, _currentDate.day);
              } else {
                _currentDate = DateTime(_currentDate.year + 1, _currentDate.month, _currentDate.day);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return FutureBuilder(
          future: _getPeriodData(provider),
          builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCards(context);
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
                        context: context,
                        title: 'Pemasukan',
                        amount: income,
                        color: AppConstants.successColor,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context: context,
                        title: 'Pengeluaran',
                        amount: expense,
                        color: AppConstants.errorColor,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSummaryCard(
                  context: context,
                  title: 'Saldo',
                  amount: balance,
                  color: AppConstants.primaryColor,
                  icon: Icons.account_balance_wallet_rounded,
                  isFullWidth: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        _buildShimmerCard(context),
      ],
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardBg, cardBg.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.formatCurrency(amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isFullWidth ? 20 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
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
                    _selectedPeriod == 0
                        ? 'Transaksi Per Hari'
                        : _selectedPeriod == 1
                        ? 'Transaksi Per Hari'
                        : 'Transaksi Per Bulan',
                    style: TextStyle(
                      fontSize: 15,
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
                      _periods[_selectedPeriod],
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ..._buildWeeklyLegend(context),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: _selectedPeriod == 0
                    ? FutureBuilder<List<Map<String, double>>>(
                        future: _getWeeklyDailyData(provider),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data = snapshot.data ?? [];
                          final labels = [
                            'Sen',
                            'Sel',
                            'Rab',
                            'Kam',
                            'Jum',
                            'Sab',
                            'Min',
                          ];
                          final now = _currentDate;
                          final highlightIdx = (now.year == DateTime.now().year && now.month == DateTime.now().month && now.day == DateTime.now().day) ? now.weekday - 1 : -1;
                          return _buildLineChart(
                            context: context,
                            data: data,
                            labels: labels,
                            highlightIndex: highlightIdx,
                          );
                        },
                      )
                    : _selectedPeriod == 1
                    ? FutureBuilder<List<Map<String, double>>>(
                        future: _getMonthlyDailyData(provider),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data = snapshot.data ?? [];
                          final now = _currentDate;
                          final daysInMonth = DateTimeRange(
                            start: DateTime(now.year, now.month, 1),
                            end: DateTime(now.year, now.month + 1, 1),
                          ).duration.inDays;
                          // Tampilkan SEMUA label tanggal (karena sekarang bisa di-scroll)
                          final labels = List.generate(
                            daysInMonth,
                            (i) => '${i + 1}',
                          );
                          return _buildLineChart(
                            context: context,
                            data: data,
                            labels: labels,
                            highlightIndex: (now.year == DateTime.now().year && now.month == DateTime.now().month && now.day == DateTime.now().day) ? now.day - 1 : -1,
                            showDotsAll: false,
                          );
                        },
                      )
                    : FutureBuilder<List<Map<String, double>>>(
                        future: _getYearlyMonthlyData(provider),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data = snapshot.data ?? [];
                          final labels = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'Mei',
                            'Jun',
                            'Jul',
                            'Agu',
                            'Sep',
                            'Okt',
                            'Nov',
                            'Des',
                          ];
                          final now = _currentDate;
                          return _buildLineChart(
                            context: context,
                            data: data,
                            labels: labels,
                            highlightIndex: (now.year == DateTime.now().year) ? now.month - 1 : -1,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildWeeklyLegend(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return [
      Row(
        children: [
          // Legend pemasukan
          Row(
            children: [
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Pemasukan',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Legend pengeluaran
          Row(
            children: [
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Pengeluaran',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Universal LineChart builder — dipakai oleh semua 3 periode
  Widget _buildLineChart({
    required BuildContext context,
    required List<Map<String, double>> data,
    required List<String> labels,
    required int highlightIndex,
    bool showDotsAll = true,
  }) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textSecondary = cs.onSurface.withOpacity(0.55);
    final dividerColor = cs.onSurface.withOpacity(0.12);

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    double maxVal = 1;

    for (int i = 0; i < data.length; i++) {
      final income = data[i]['income'] ?? 0.0;
      final expense = data[i]['expense'] ?? 0.0;
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
      if (income > maxVal) maxVal = income;
      if (expense > maxVal) maxVal = expense;
    }

    final maxX = ((data.length - 1).toDouble()).clamp(1.0, double.infinity);
    final hInterval = maxVal / 4 < 1 ? 1.0 : maxVal / 4;

    final chartWidget = Padding(
      padding: const EdgeInsets.only(right: 22, top: 10),
      child: LineChart(
        LineChartData(
        maxX: maxX,
        minX: 0,
        maxY: maxVal * 1.5, // Tambah batas atas agar tooltip panjang tidak terpotong
        minY: 0,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (spot) => cardBg,
            tooltipBorder: BorderSide(color: dividerColor, width: 1),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isIncome = spot.barIndex == 0;
                final label = spot.x.toInt() < labels.length
                    ? labels[spot.x.toInt()]
                    : '';
                
                // Hanya tampilkan tanggal di item pertama agar tidak ganda
                final isFirst = touchedSpots.indexOf(spot) == 0;
                final dateStr = (isFirst && label.isNotEmpty) ? 'Tgl $label\n' : '';
                
                return LineTooltipItem(
                  '$dateStr${isIncome ? 'Pemasukan: ' : 'Pengeluaran: '}${CurrencyFormatter.formatCompact(spot.y)}',
                  TextStyle(
                    color: isIncome
                        ? AppConstants.successColor
                        : AppConstants.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: dividerColor.withOpacity(0.5), width: 1),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: hInterval,
          verticalInterval: maxX / 6,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: dividerColor.withOpacity(0.3), strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: dividerColor.withOpacity(0.3), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    CurrencyFormatter.formatCompact(value),
                    style: TextStyle(color: textSecondary, fontSize: 9),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36, // sedikit diperbesar untuk teks miring
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                final label = labels[idx];
                if (label.isEmpty) return const SizedBox.shrink();
                final isHighlight = idx == highlightIndex;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Transform.rotate(
                    angle: -0.6, // Teks miring agar tidak bertabrakan
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isHighlight
                            ? AppConstants.primaryColor
                            : textSecondary,
                        fontSize: 9, // Diperkecil sedikit agar muat
                        fontWeight: isHighlight
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          // Garis Pemasukan (hijau)
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppConstants.successColor,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppConstants.successColor.withOpacity(0.18),
                  AppConstants.successColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final isHighlight = index == highlightIndex;
                final show = showDotsAll || isHighlight;
                if (!show) {
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                }
                return FlDotCirclePainter(
                  radius: isHighlight ? 5.5 : 3,
                  color: AppConstants.successColor,
                  strokeWidth: isHighlight ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          // Garis Pengeluaran (merah)
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppConstants.errorColor,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppConstants.errorColor.withOpacity(0.15),
                  AppConstants.errorColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final isHighlight = index == highlightIndex;
                final show = showDotsAll || isHighlight;
                if (!show) {
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                }
                return FlDotCirclePainter(
                  radius: isHighlight ? 5.5 : 3,
                  color: AppConstants.errorColor,
                  strokeWidth: isHighlight ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
      ),
    );

    // Jika data terlalu banyak (seperti bulanan), jadikan scrollable
    if (data.length > 12) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: data.length * 30.0, // 30 px per tanggal
                child: chartWidget,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, size: 12, color: textSecondary),
              const SizedBox(width: 6),
              Text(
                '* Geser grafik untuk melihat detail',
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return chartWidget;
  }

  Future<List<Map<String, double>>> _getWeeklyDailyData(
    TransactionProvider provider,
  ) async {
    final now = _currentDate;
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final List<Map<String, double>> result = [];
    for (int i = 0; i < 7; i++) {
      final dayStart = startOfWeek.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final transactions = await provider.getTransactionsByDateRange(
        dayStart,
        dayEnd,
      );
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
      result.add({'income': income, 'expense': expense});
    }
    return result;
  }

  Future<List<Map<String, double>>> _getMonthlyDailyData(
    TransactionProvider provider,
  ) async {
    final now = _currentDate;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ).difference(startOfMonth).inDays;

    final List<Map<String, double>> result = [];
    for (int i = 0; i < daysInMonth; i++) {
      final dayStart = startOfMonth.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final transactions = await provider.getTransactionsByDateRange(
        dayStart,
        dayEnd,
      );
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
      result.add({'income': income, 'expense': expense});
    }
    return result;
  }

  Future<List<Map<String, double>>> _getYearlyMonthlyData(
    TransactionProvider provider,
  ) async {
    final now = _currentDate;
    final List<Map<String, double>> result = [];
    for (int month = 1; month <= 12; month++) {
      final startOfMonth = DateTime(now.year, month, 1);
      final endOfMonth = DateTime(now.year, month + 1, 1);
      final transactions = await provider.getTransactionsByDateRange(
        startOfMonth,
        endOfMonth,
      );
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
      result.add({'income': income, 'expense': expense});
    }
    return result;
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardBg = cs.surface;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.55);

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
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
                'Breakdown Pengeluaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: provider.getExpensesByCategory(_currentDate),
                builder:
                    (context, AsyncSnapshot<Map<String, double>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pie_chart_outline,
                                size: 48,
                                color: textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada data pengeluaran',
                                style: TextStyle(color: textSecondary),
                              ),
                            ],
                          ),
                        );
                      }

                      final expensesByCategory = snapshot.data!;
                      final sortedCategories =
                          expensesByCategory.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));

                      final totalExpense = sortedCategories.fold<double>(
                        0,
                        (sum, entry) => sum + entry.value,
                      );

                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: sortedCategories.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final category = entry.value;
                                  final percentage =
                                      (category.value / totalExpense * 100);
                                  final color =
                                      AppConstants.chartColors[index %
                                          AppConstants.chartColors.length];

                                  return PieChartSectionData(
                                    value: category.value,
                                    title: percentage > 5
                                        ? '${percentage.toInt()}%'
                                        : '',
                                    color: color,
                                    radius: 65,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...sortedCategories.take(5).map((entry) {
                            final percentage =
                                (entry.value / totalExpense * 100);
                            final colorIndex =
                                sortedCategories.indexOf(entry) %
                                AppConstants.chartColors.length;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          AppConstants.chartColors[colorIndex],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants
                                          .chartColors[colorIndex]
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${percentage.toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppConstants
                                            .chartColors[colorIndex],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    CurrencyFormatter.formatCompact(
                                      entry.value,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
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
        );
      },
    );
  }

  Future<Map<String, double>> _getPeriodData(
    TransactionProvider provider,
  ) async {
    final now = _currentDate;

    switch (_selectedPeriod) {
      case 0:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
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

      case 1:
        final income = await provider.getTotalIncomeByMonth(now);
        final expense = await provider.getTotalExpenseByMonth(now);

        return {'income': income, 'expense': expense};

      case 2:
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

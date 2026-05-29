import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfessionalChartWidget extends StatefulWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final bool showLegend;

  const ProfessionalChartWidget({
    Key? key,
    required this.incomeData,
    required this.expenseData,
    this.showLegend = true,
  }) : super(key: key);

  @override
  State<ProfessionalChartWidget> createState() => _ProfessionalChartWidgetState();
}

class _ProfessionalChartWidgetState extends State<ProfessionalChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(),
            ),
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.incomeData.fold<double>(0, (a, b) => a + b) +
        widget.expenseData.fold<double>(0, (a, b) => a + b);

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.3),
          value: 1,
          showTitle: false,
          radius: 40,
        ),
      ];
    }

    final incomeTotal = widget.incomeData.fold<double>(0, (a, b) => a + b);
    final expenseTotal = widget.expenseData.fold<double>(0, (a, b) => a + b);

    return [
      PieChartSectionData(
        color: AppConstants.successColor,
        value: incomeTotal > 0 ? incomeTotal : 0.1,
        title: _touchedIndex == 0
            ? '${((incomeTotal / total) * 100).toStringAsFixed(1)}%'
            : '',
        radius: _touchedIndex == 0 ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: incomeTotal > 0
            ? _Badge(
                icon: Icons.arrow_downward,
                color: AppConstants.successColor,
                isIncome: true,
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      ),
      PieChartSectionData(
        color: AppConstants.errorColor,
        value: expenseTotal > 0 ? expenseTotal : 0.1,
        title: _touchedIndex == 1
            ? '${((expenseTotal / total) * 100).toStringAsFixed(1)}%'
            : '',
        radius: _touchedIndex == 1 ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: expenseTotal > 0
            ? _Badge(
                icon: Icons.arrow_upward,
                color: AppConstants.errorColor,
                isIncome: false,
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: AppConstants.successColor,
          label: 'Pemasukan',
          icon: Icons.arrow_downward,
        ),
        const SizedBox(width: 32),
        _buildLegendItem(
          color: AppConstants.errorColor,
          label: 'Pengeluaran',
          icon: Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isIncome;

  const _Badge({
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            isIncome ? 'In' : 'Out',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetModel {
  final int? id;
  final String category;
  final double amountLimit;
  final BudgetPeriod period;
  final DateTime createdAt;

  BudgetModel({
    this.id,
    required this.category,
    required this.amountLimit,
    required this.period,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount_limit': amountLimit,
      'period': period.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (SQLite)
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amountLimit: map['amount_limit'] as double,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method
  BudgetModel copyWith({
    int? id,
    String? category,
    double? amountLimit,
    BudgetPeriod? period,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amountLimit: amountLimit ?? this.amountLimit,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum BudgetPeriod {
  weekly,
  monthly,
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Mingguan';
      case BudgetPeriod.monthly:
        return 'Bulanan';
    }
  }
}

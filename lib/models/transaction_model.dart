class TransactionModel {
  final int? id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;
  final String? imagePath;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (SQLite)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method
  TransactionModel copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum TransactionType {
  income,
  expense,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }
}

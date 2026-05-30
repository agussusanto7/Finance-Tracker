import 'package:intl/intl.dart';

class TransactionModel {
  final String? id;
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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type == TransactionType.income ? 'pemasukan' : 'pengeluaran',
      'category': category,
      // Merapikan tanggal agar enak dilihat di database (tanpa huruf T dan milidetik)
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'note': note,
      'image_path': imagePath,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
    };
  }

  // Create from Map (Firestore)
  factory TransactionModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TransactionModel(
      id: docId ?? map['id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'pemasukan' 
          ? TransactionType.income 
          : TransactionType.expense,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method
  TransactionModel copyWith({
    String? id,
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

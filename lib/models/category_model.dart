import 'transaction_model.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final TransactionType type;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
    };
  }

  // Create from Map (SQLite)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
    );
  }

  // Copy with method
  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    TransactionType? type,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}

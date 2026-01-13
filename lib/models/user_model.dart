class UserModel {
  final int? id;
  final String name;
  final String? photoPath;
  final String? pin;
  final bool biometricEnabled;
  final bool balanceHidden;
  final String currency;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    this.photoPath,
    this.pin,
    this.biometricEnabled = false,
    this.balanceHidden = false,
    this.currency = 'IDR',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for SQLite (for insert)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo_path': photoPath,
      'pin': pin,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'balance_hidden': balanceHidden ? 1 : 0,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert to Map for SQLite (for update)
  Map<String, dynamic> toMapForUpdate() {
    final map = <String, dynamic>{
      'name': name,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'balance_hidden': balanceHidden ? 1 : 0,
      'currency': currency,
    };

    // Only add nullable fields if they have values
    if (photoPath != null) {
      map['photo_path'] = photoPath;
    }
    if (pin != null) {
      map['pin'] = pin;
    }

    return map;
  }

  // Create from Map (SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      photoPath: map['photo_path'] as String?,
      pin: map['pin'] as String?,
      biometricEnabled: (map['biometric_enabled'] as int) == 1,
      balanceHidden: (map['balance_hidden'] as int) == 1,
      currency: map['currency'] as String? ?? 'IDR',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method
  UserModel copyWith({
    int? id,
    String? name,
    String? photoPath,
    String? pin,
    bool? biometricEnabled,
    bool? balanceHidden,
    String? currency,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      pin: pin ?? this.pin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      balanceHidden: balanceHidden ?? this.balanceHidden,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

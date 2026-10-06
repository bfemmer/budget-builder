import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    super.id,
    required super.description,
    required super.categoryId,
    required super.date,
    required super.amount,
    required super.vendor,
    required super.paymentType,
    required super.needOrWant,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      description: map['description'] ?? '',
      categoryId: map['category_id'] ?? 0,
      date: map['date'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      vendor: map['vendor'] ?? '',
      paymentType: map['payment_type'] ?? 'Cash',
      needOrWant: map['need_or_want'] ?? 'Need',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'category_id': categoryId,
      'date': date,
      'amount': amount,
      'vendor': vendor,
      'payment_type': paymentType,
      'need_or_want': needOrWant,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? description,
    int? categoryId,
    String? date,
    double? amount,
    String? vendor,
    String? paymentType,
    String? needOrWant,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      vendor: vendor ?? this.vendor,
      paymentType: paymentType ?? this.paymentType,
      needOrWant: needOrWant ?? this.needOrWant,
    );
  }
}

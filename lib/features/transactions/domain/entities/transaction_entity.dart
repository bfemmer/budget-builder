class TransactionEntity {
  final int? id;
  final String description;
  final int categoryId;
  final String date; // ISO string YYYY-MM-DD
  final double amount;
  final String vendor;
  final String paymentType; // "Cash" or "Credit"
  final String needOrWant;   // "Need" or "Want"

  TransactionEntity({
    this.id,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.amount,
    required this.vendor,
    required this.paymentType,
    required this.needOrWant,
  });

  bool get isNeed => needOrWant == 'Need';
  bool get isCredit => paymentType == 'Credit';
}

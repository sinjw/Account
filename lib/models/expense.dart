class Expense {
  final int? id;
  final int amount;
  final DateTime date;
  final String memo;
  final String paymentMethod;

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.memo,
    this.paymentMethod = 'card',
  });
}

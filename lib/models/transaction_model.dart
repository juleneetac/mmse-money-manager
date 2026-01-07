class TransactionModel {
  final double amount;
  final String type; // 'income' | 'expense'
  final String category;
  final DateTime date;

  TransactionModel({
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });
}

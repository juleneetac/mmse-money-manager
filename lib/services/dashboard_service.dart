import '../models/transaction_model.dart';

class DashboardService {
  static double totalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double totalExpense(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static Map<String, double> expenseByCategory(
    List<TransactionModel> transactions,
  ) {
    final Map<String, double> result = {};

    for (var t in transactions.where((e) => e.type == 'expense')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }

    return result;
  }
}

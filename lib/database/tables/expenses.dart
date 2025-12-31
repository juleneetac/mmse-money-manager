import 'package:drift/drift.dart';
import 'categories.dart';

// Expenses table
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Expense amount (EUR for now)
  RealColumn get amount => real()();

  // Optional description
  TextColumn get description => text().nullable()();

  // Expense date
  DateTimeColumn get date => dateTime()();

  // Reference to category
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
}

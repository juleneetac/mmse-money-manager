import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../services/expense_service.dart';
import '../services/category_service.dart';
import '../services/preferences_service.dart';
import '../utils/validators.dart';

/// Screen used to add a new expense
class AddExpenseScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddExpenseScreen({super.key, required this.selectedDate});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  // Text controllers for inputs
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  // Database & service
  late final ExpenseService expenseService;
  late final CategoryService categoryService;

  // Categories state
  List<Category> categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase(); // singleton access
    final prefs = PreferencesService();
    expenseService = ExpenseService(db);
    categoryService = CategoryService(db, prefs);
    _loadCategories();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Load categories from local database
  Future<void> _loadCategories() async {
    final result = await categoryService.getCategories();
    setState(() => categories = result);
  }

  Future<void> _saveExpense() async {
    // 1. Trigger validation for all fields in the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if any field is invalid
    }

    // If we are here, the data is guaranteed to be valid
    final amount = double.parse(amountController.text);
    final normalizedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    await expenseService.saveExpense(
      amount: amount,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text,
      categoryId: selectedCategoryId!,
      date: normalizedDate,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      // SafeArea prevents the nav bar overlap
      body: SafeArea(
        // SingleChildScrollView prevents keyboard crash
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                  validator: AppValidators.validateAmount,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategoryId = val),
                  validator: AppValidators.validateCategory,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

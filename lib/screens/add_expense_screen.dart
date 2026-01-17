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
      body: Padding(
        padding: const EdgeInsets.all(16),
        // 2. Wrap everything in a Form
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount Input with Validator
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (€)',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator:
                    AppValidators.validateAmount, // 👈 Using the validator
              ),

              const SizedBox(height: 16),

              // Category Dropdown with Validator
              DropdownButtonFormField<int>(
                initialValue : selectedCategoryId,
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
                validator:
                    AppValidators.validateCategory, // Using the validator
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),

              const Spacer(),

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
    );
  }
  // /// Validate inputs and save expense
  // Future<void> _saveExpense() async {
  //   final amount = double.tryParse(amountController.text);
  //   final normalizedDate = DateTime(
  //     widget.selectedDate.year,
  //     widget.selectedDate.month,
  //     widget.selectedDate.day,
  //   );

  //   // Basic validation
  //   if (amount == null || amount <= 0 || selectedCategoryId == null) {
  //     return;
  //   }

  //   await expenseService.saveExpense(
  //     amount: amount,
  //     description: descriptionController.text.isEmpty
  //         ? null
  //         : descriptionController.text,
  //     categoryId: selectedCategoryId!,
  //     date: normalizedDate,
  //   );

  //   // Close screen after saving
  //   if (mounted) {
  //     Navigator.pop(context);
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Add Expense')),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           // Amount input
  //           TextField(
  //             controller: amountController,
  //             keyboardType: TextInputType.number,
  //             decoration: const InputDecoration(labelText: 'Amount (€)'),
  //           ),

  //           const SizedBox(height: 12),

  //           // Category dropdown
  //           DropdownButtonFormField<int>(
  //             initialValue: selectedCategoryId,
  //             decoration: const InputDecoration(labelText: 'Category'),
  //             items:
  //                 //show the list of categories sorted
  //                 (List.of(categories)..sort(
  //                       (a, b) => a.name.toLowerCase().compareTo(
  //                         b.name.toLowerCase(),
  //                       ),
  //                     ))
  //                     .map((category) {
  //                       return DropdownMenuItem<int>(
  //                         value: category.id,
  //                         child: Text(category.name),
  //                       );
  //                     })
  //                     .toList(),
  //             onChanged: (value) {
  //               setState(() => selectedCategoryId = value);
  //             },
  //           ),

  //           const SizedBox(height: 12),

  //           // Optional description
  //           TextField(
  //             controller: descriptionController,
  //             decoration: const InputDecoration(
  //               labelText: 'Description (optional)',
  //             ),
  //           ),

  //           const SizedBox(height: 12),

  //           Text(
  //             'Date: ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
  //             style: const TextStyle(fontSize: 16),
  //           ),

  //           const Spacer(),

  //           // Save expense button
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: _saveExpense,
  //               child: const Text('Save Expense'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../services/expense_service.dart';
import '../services/category_service.dart';
import '../services/preferences_service.dart';
import '../utils/validators.dart'; // Import your validators

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  // 1. Add the Form Key
  final _formKey = GlobalKey<FormState>();

  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late ExpenseService expenseService;
  late CategoryService categoryService;

  List<Category> categories = [];
  int? selectedCategoryId;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase();
    final prefs = PreferencesService();
    expenseService = ExpenseService(db);
    categoryService = CategoryService(db, prefs);

    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    descriptionController = TextEditingController(
      text: widget.expense.description ?? '',
    );
    selectedCategoryId = widget.expense.categoryId;
    selectedDate = widget.expense.date;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await categoryService.getCategories();
    setState(() => categories = result);
  }

  Future<void> _updateExpense() async {
    // Validate form before processing
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(amountController.text);

    await expenseService.updateExpense(
      widget.expense,
      amount: amount,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text,
      categoryId: selectedCategoryId!,
      date: selectedDate,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // 3. Wrap in Form
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount TextFormField
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

              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<int>(
                initialValue: selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                // Sort categories alphabetically
                items:
                    (List.of(categories)..sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                            b.name.toLowerCase(),
                          ),
                        ))
                        .map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        })
                        .toList(),
                onChanged: (value) =>
                    setState(() => selectedCategoryId = value),
                validator: AppValidators.validateCategory,
              ),

              const SizedBox(height: 12),

              // Description TextFormField
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateExpense,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/financial_goal.dart';

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  String _priority = 'medium';
  String? _selectedCategory;
  bool _useCustomCategory = false;

  final List<String> _predefinedCategories = [
    'Emergency Fund',
    'Vacation',
    'New Phone',
    'New Laptop',
    'Car Purchase',
    'Home Down Payment',
    'Education',
    'Investment',
    'Debt Payoff',
    'Other',
  ];

  final List<String> _priorities = ['low', 'medium', 'high'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Create Financial Goal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildLabel('Goal Title'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('Enter goal title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Description (Optional)'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        'Enter goal description',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Target Amount
                    _buildLabel('Target Amount'),
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: _buildInputDecoration(
                        'Enter target amount',
                      ).copyWith(prefixText: '₹ '),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a target amount';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    _buildLabel('Category'),
                    if (!_useCustomCategory) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _buildInputDecoration('Select a category'),
                        items: _predefinedCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                Text(_getCategoryIcon(category)),
                                const SizedBox(width: 8),
                                Text(category),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _useCustomCategory = true;
                            _selectedCategory = null;
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Custom Category'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _categoryController,
                        decoration: _buildInputDecoration(
                          'Enter custom category name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _useCustomCategory = false;
                            _categoryController.clear();
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Use Predefined Categories'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Target Date
                    _buildLabel('Target Date'),
                    InkWell(
                      onTap: _selectTargetDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Priority
                    _buildLabel('Priority'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _priorities.map((priority) {
                          final isSelected = _priority == priority;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _priority = priority;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getPriorityColor(priority)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_getPriorityIcon(priority)),
                                  const SizedBox(width: 4),
                                  Text(
                                    priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Monthly Savings Preview
                    if (_targetAmountController.text.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 Monthly Savings Required',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You need to save ₹${_calculateMonthlySavings().toStringAsFixed(0)} per month to reach your goal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Create Goal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  double _calculateMonthlySavings() {
    final amount = double.tryParse(_targetAmountController.text.trim()) ?? 0;
    final now = DateTime.now();
    final monthsLeft =
        ((_targetDate.year - now.year) * 12) + (_targetDate.month - now.month);
    if (monthsLeft <= 0) return amount;
    return amount / monthsLeft;
  }

  void _createGoal() {
    if (_formKey.currentState!.validate()) {
      final category = _useCustomCategory
          ? _categoryController.text.trim()
          : _selectedCategory!;

      final targetAmount = double.parse(_targetAmountController.text.trim());
      final description = _descriptionController.text.trim();

      final goal = FinancialGoal(
        title: _titleController.text.trim(),
        description: description.isNotEmpty ? description : null,
        targetAmount: targetAmount,
        targetDate: _targetDate,
        priority: _priority,
        category: category,
        createdAt: DateTime.now(),
      );

      Navigator.of(context).pop(goal);
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'emergency fund':
        return '🚨';
      case 'vacation':
        return '🏖️';
      case 'new phone':
        return '📱';
      case 'new laptop':
        return '💻';
      case 'car purchase':
        return '🚗';
      case 'home down payment':
        return '🏠';
      case 'education':
        return '📚';
      case 'investment':
        return '📈';
      case 'debt payoff':
        return '💳';
      default:
        return '🎯';
    }
  }

  String _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/financial_goal.dart';

class UpdateProgressDialog extends StatefulWidget {
  final FinancialGoal goal;

  const UpdateProgressDialog({super.key, required this.goal});

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isAddAmount = true; // true for add, false for set specific amount
  double get _currentAmount => widget.goal.currentAmount;
  double get _targetAmount => widget.goal.targetAmount;
  double get _remainingAmount => _targetAmount - _currentAmount;

  @override
  void initState() {
    super.initState();
    _amountController.text = '0';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Update Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Amount'),
                                  Text(
                                    '₹${_currentAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Target Amount'),
                                  Text(
                                    '₹${_targetAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _currentAmount / _targetAmount,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progress: ${((_currentAmount / _targetAmount) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Remaining: ₹${_remainingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Update Type Selection
                    const Text(
                      'Update Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Add Amount'),
                            subtitle: const Text('Add to current progress'),
                            value: true,
                            groupValue: _isAddAmount,
                            onChanged: (value) {
                              setState(() {
                                _isAddAmount = value!;
                                _amountController.text = '0';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Set Total'),
                            subtitle: const Text('Set total saved amount'),
                            value: false,
                            groupValue: _isAddAmount,
                            onChanged: (value) {
                              setState(() {
                                _isAddAmount = value!;
                                _amountController.text = _currentAmount
                                    .toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: _isAddAmount
                              ? 'Amount to Add (₹)'
                              : 'Total Amount (₹)',
                          hintText: _isAddAmount ? 'e.g., 5000' : 'e.g., 25000',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value!);
                          if (amount == null || amount < 0) {
                            return 'Please enter a valid amount';
                          }

                          double newTotal;
                          if (_isAddAmount) {
                            newTotal = _currentAmount + amount;
                          } else {
                            newTotal = amount;
                          }

                          if (newTotal > _targetAmount) {
                            return 'Amount exceeds target (₹${_targetAmount.toStringAsFixed(0)})';
                          }

                          if (!_isAddAmount && amount < _currentAmount) {
                            return 'Total amount cannot be less than current (₹${_currentAmount.toStringAsFixed(0)})';
                          }

                          return null;
                        },
                        onChanged: (value) {
                          setState(() {}); // Trigger rebuild to update preview
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preview
                    if (_amountController.text.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPreviewRow(),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Quick Amount Buttons
                    if (_isAddAmount && _remainingAmount > 0) ...[
                      const Text(
                        'Quick Add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getQuickAmounts().map((amount) {
                          return OutlinedButton(
                            onPressed: () {
                              _amountController.text = amount.toString();
                              setState(() {});
                            },
                            child: Text('₹$amount'),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Update Progress'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow() {
    final inputAmount = double.tryParse(_amountController.text) ?? 0;
    final newTotal = _isAddAmount ? _currentAmount + inputAmount : inputAmount;
    final newProgress = (newTotal / _targetAmount * 100);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('New Total:'),
            Text(
              '₹${newTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress:'),
            Text(
              '${newProgress.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Remaining:'),
            Text(
              '₹${(_targetAmount - newTotal).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  List<int> _getQuickAmounts() {
    final suggestions = <int>[];
    final remaining = _remainingAmount.toInt();

    // Add common amounts
    const commonAmounts = [500, 1000, 2000, 5000, 10000];
    for (final amount in commonAmounts) {
      if (amount <= remaining) {
        suggestions.add(amount);
      }
    }

    // Add 25%, 50%, 75% of remaining
    for (final percentage in [0.25, 0.5, 0.75]) {
      final amount = (remaining * percentage).round();
      if (amount >= 100 && !suggestions.contains(amount)) {
        suggestions.add(amount);
      }
    }

    // Add full remaining amount if not too large
    if (remaining <= 100000 && !suggestions.contains(remaining)) {
      suggestions.add(remaining);
    }

    suggestions.sort();
    return suggestions.take(6).toList(); // Limit to 6 suggestions
  }

  void _updateProgress() {
    if (_formKey.currentState?.validate() ?? false) {
      final inputAmount = double.parse(_amountController.text);
      final newAmount = _isAddAmount
          ? _currentAmount + inputAmount
          : inputAmount;

      Navigator.of(context).pop(newAmount);
    }
  }
}

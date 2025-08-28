import 'package:flutter/material.dart';
import '../models/financial_goal.dart';
import '../services/database_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/edit_goal_dialog.dart';
import '../widgets/update_progress_dialog.dart';
import '../widgets/custom_app_bar.dart';

class FinancialGoalsScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const FinancialGoalsScreen({super.key, this.onToggleTheme});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<FinancialGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await _databaseService.getFinancialGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading goals: $e')));
      }
    }
  }

  Future<void> _showAddGoalDialog() async {
    final result = await showDialog<FinancialGoal>(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );

    if (result != null) {
      try {
        await _databaseService.insertFinancialGoal(result);
        _loadGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Financial goal created successfully!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating goal: $e')));
        }
      }
    }
  }

  List<FinancialGoal> get _activeGoals =>
      _goals.where((goal) => goal.status == 'active').toList();
  List<FinancialGoal> get _completedGoals =>
      _goals.where((goal) => goal.status == 'completed').toList();

  double get _totalTargetAmount =>
      _activeGoals.fold(0, (sum, goal) => sum + goal.targetAmount);
  double get _totalCurrentAmount =>
      _activeGoals.fold(0, (sum, goal) => sum + goal.currentAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '🎯 Financial Goals',
        onToggleTheme: widget.onToggleTheme,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: Column(
                children: [
                  // Summary Card
                  if (_activeGoals.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4361ee),
                            const Color(0xFF4895ef),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Goals Progress Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSummaryItem(
                                'Active Goals',
                                '${_activeGoals.length}',
                                Colors.white,
                              ),
                              _buildSummaryItem(
                                'Total Target',
                                '₹${_totalTargetAmount.toStringAsFixed(0)}',
                                Colors.white,
                              ),
                              _buildSummaryItem(
                                'Total Saved',
                                '₹${_totalCurrentAmount.toStringAsFixed(0)}',
                                Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _totalTargetAmount > 0
                                ? _totalCurrentAmount / _totalTargetAmount
                                : 0,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_totalTargetAmount > 0 ? (_totalCurrentAmount / _totalTargetAmount * 100) : 0).toStringAsFixed(1)}% of total goals achieved',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Goals List
                  Expanded(
                    child: _goals.isEmpty
                        ? _buildEmptyState()
                        : DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                const TabBar(
                                  labelColor: Colors.black,
                                  tabs: [
                                    Tab(text: 'Active Goals'),
                                    Tab(text: 'Completed Goals'),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildGoalsList(
                                        _activeGoals,
                                        'No active goals yet',
                                      ),
                                      _buildGoalsList(
                                        _completedGoals,
                                        'No completed goals yet',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(List<FinancialGoal> goals, String emptyMessage) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCard(
          goal: goal,
          onTap: () => _showGoalDetails(goal),
          onEdit: () => _editGoal(goal),
          onDelete: () => _deleteGoal(goal),
          onUpdateProgress: () => _updateGoalProgress(goal),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Financial Goals Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your first financial goal to start\nyour journey towards financial success',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddGoalDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(FinancialGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        goal.priorityIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: goal.isCompleted ? Colors.green : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          goal.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (goal.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      goal.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Target Amount',
                    '₹${goal.targetAmount.toStringAsFixed(0)}',
                  ),
                  _buildDetailRow(
                    'Current Amount',
                    '₹${goal.currentAmount.toStringAsFixed(0)}',
                  ),
                  _buildDetailRow(
                    'Remaining',
                    '₹${goal.remainingAmount.toStringAsFixed(0)}',
                  ),
                  _buildDetailRow(
                    'Progress',
                    '${(goal.progressPercentage * 100).toStringAsFixed(1)}%',
                  ),
                  _buildDetailRow(
                    'Target Date',
                    '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                  ),
                  _buildDetailRow(
                    'Days Remaining',
                    '${goal.daysRemaining} days',
                  ),
                  _buildDetailRow(
                    'Monthly Saving Required',
                    '₹${goal.requiredMonthlySaving.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: goal.progressPercentage > 1
                        ? 1
                        : goal.progressPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? Colors.green : Colors.blue,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _updateGoalProgress(FinancialGoal goal) async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => UpdateProgressDialog(goal: goal),
    );

    if (result != null) {
      try {
        await _databaseService.updateGoalProgress(goal.id!, result);
        _loadGoals();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal progress updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating progress: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editGoal(FinancialGoal goal) async {
    final result = await showDialog<FinancialGoal>(
      context: context,
      builder: (context) => EditGoalDialog(goal: goal),
    );

    if (result != null) {
      try {
        await _databaseService.updateFinancialGoal(result);
        _loadGoals();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating goal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteGoal(FinancialGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete "'),
              TextSpan(
                text: goal.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '"?\n\nThis action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteFinancialGoal(goal.id!);
        _loadGoals();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${goal.title}" deleted successfully!'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    // Re-insert the deleted goal
                    await _databaseService.insertFinancialGoal(goal);
                    _loadGoals();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Goal restored successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to restore goal: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting goal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/transaction.dart';

class InvestmentPortfolioScreen extends StatefulWidget {
  const InvestmentPortfolioScreen({super.key});

  @override
  State<InvestmentPortfolioScreen> createState() =>
      _InvestmentPortfolioScreenState();
}

class _InvestmentPortfolioScreenState extends State<InvestmentPortfolioScreen> {
  // Controllers for add investment form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _currentPriceController = TextEditingController();
  InvestmentType? _selectedType;

  final List<Investment> _investments = [
    Investment(
      id: '1',
      name: 'Reliance Industries',
      symbol: 'RELIANCE',
      currentPrice: 2456.75,
      purchasePrice: 2200.00,
      quantity: 50,
      purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      type: InvestmentType.stock,
    ),
    Investment(
      id: '2',
      name: 'SBI Bluechip Fund',
      symbol: 'SBI-BC',
      currentPrice: 67.84,
      purchasePrice: 65.20,
      quantity: 1000,
      purchaseDate: DateTime.now().subtract(const Duration(days: 45)),
      type: InvestmentType.mutualFund,
    ),
    Investment(
      id: '3',
      name: 'HDFC Bank',
      symbol: 'HDFCBANK',
      currentPrice: 1654.30,
      purchasePrice: 1580.00,
      quantity: 25,
      purchaseDate: DateTime.now().subtract(const Duration(days: 20)),
      type: InvestmentType.stock,
    ),
    Investment(
      id: '4',
      name: 'Bitcoin',
      symbol: 'BTC',
      currentPrice: 4235000.00,
      purchasePrice: 3800000.00,
      quantity: 1,
      purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
      type: InvestmentType.crypto,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalValue = _investments.fold<double>(
      0,
      (sum, inv) => sum + inv.totalValue,
    );
    final totalCost = _investments.fold<double>(
      0,
      (sum, inv) => sum + inv.totalCost,
    );
    final totalProfit = totalValue - totalCost;
    final profitPercentage = (totalProfit / totalCost) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Portfolio'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalyticsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPortfolioSummary(
            totalValue,
            totalCost,
            totalProfit,
            profitPercentage,
          ),
          _buildPerformanceIndicators(),
          Expanded(child: _buildInvestmentsList()),
        ],
      ),
      floatingActionButton: _buildAnimatedFab(),
    );
  }

  bool _fabActive = false;

  Widget _buildAnimatedFab() {
    return GestureDetector(
      onTap: () async {
        setState(() => _fabActive = true);
        _showAddInvestmentDialog();
        if (mounted) setState(() => _fabActive = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          // animate from rounded square (16) to full circle (29)
          borderRadius: BorderRadius.circular(_fabActive ? 29 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  Widget _buildPortfolioSummary(
    double totalValue,
    double totalCost,
    double totalProfit,
    double profitPercentage,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                totalProfit >= 0 ? Colors.green : Colors.red,
                (totalProfit >= 0 ? Colors.green : Colors.red).withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Portfolio Value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${totalValue.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPortfolioMetric(
                    'Invested',
                    '₹${totalCost.toStringAsFixed(0)}',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildPortfolioMetric(
                    totalProfit >= 0 ? 'Profit' : 'Loss',
                    '₹${totalProfit.abs().toStringAsFixed(0)} (${profitPercentage.toStringAsFixed(1)}%)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicators() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildPerformanceCard(
              'Today\'s Gain',
              '+₹2,340',
              '+1.2%',
              true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPerformanceCard(
              'Total Return',
              '+₹15,670',
              '+8.4%',
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String amount,
    String percentage,
    bool isPositive,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _investments.length,
        itemBuilder: (context, index) {
          final inv = _investments[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Dismissible(
                  key: ValueKey(inv.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Delete Investment'),
                            content: Text(
                              'Are you sure you want to delete ${inv.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dCtx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) => _deleteInvestment(inv.id),
                  child: _buildInvestmentCard(inv),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
    final isProfit = investment.profit >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => _showInvestmentDetails(investment),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getInvestmentTypeColor(
                        investment.type,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getInvestmentTypeIcon(investment.type),
                      color: _getInvestmentTypeColor(investment.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investment.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${investment.symbol} • ${investment.quantity} units',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        _showInvestmentDetails(investment);
                      } else if (value == 'delete') {
                        _confirmDelete(investment);
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'view', child: Text('View Details')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${investment.totalValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}₹${investment.profit.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInvestmentDetail(
                    'Current Price',
                    '₹${investment.currentPrice.toStringAsFixed(2)}',
                  ),
                  _buildInvestmentDetail(
                    'Purchase Price',
                    '₹${investment.purchasePrice.toStringAsFixed(2)}',
                  ),
                  _buildInvestmentDetail(
                    'Return',
                    '${investment.profitPercentage >= 0 ? '+' : ''}${investment.profitPercentage.toStringAsFixed(1)}%',
                    color: profitColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: investment.profitPercentage / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(profitColor),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentDetail(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Color _getInvestmentTypeColor(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return Colors.blue;
      case InvestmentType.mutualFund:
        return Colors.green;
      case InvestmentType.etf:
        return Colors.orange;
      case InvestmentType.bond:
        return Colors.purple;
      case InvestmentType.crypto:
        return Colors.amber;
    }
  }

  IconData _getInvestmentTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return Icons.trending_up;
      case InvestmentType.mutualFund:
        return Icons.account_balance;
      case InvestmentType.etf:
        return Icons.show_chart;
      case InvestmentType.bond:
        return Icons.receipt_long;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
    }
  }

  void _showAddInvestmentDialog() {
    _nameController.clear();
    _symbolController.clear();
    _purchasePriceController.clear();
    _quantityController.clear();
    _currentPriceController.clear();
    _selectedType = null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Add Investment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Investment Name',
                    hintText: 'e.g., Apple Inc.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    hintText: 'e.g., AAPL',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _purchasePriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Price',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Current Price (optional)',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<InvestmentType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Investment Type',
                  ),
                  items: InvestmentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setLocalState(() => _selectedType = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addInvestmentFromDialog();
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addInvestmentFromDialog() {
    final name = _nameController.text.trim();
    final symbol = _symbolController.text.trim();
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim());
    final currentPrice = double.tryParse(_currentPriceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());
    final type = _selectedType;

    if (name.isEmpty ||
        symbol.isEmpty ||
        purchasePrice == null ||
        quantity == null ||
        type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    final inv = Investment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      symbol: symbol.toUpperCase(),
      currentPrice: currentPrice ?? purchasePrice,
      purchasePrice: purchasePrice,
      quantity: quantity,
      purchaseDate: DateTime.now(),
      type: type,
    );

    setState(() => _investments.add(inv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Investment added successfully!')),
    );
  }

  void _showInvestmentDetails(Investment investment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isProfit = investment.profit >= 0;
        final profitColor = isProfit ? Colors.green : Colors.red;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getInvestmentTypeIcon(investment.type),
                    color: _getInvestmentTypeColor(investment.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      investment.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDelete(investment);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _detailChip('Symbol', investment.symbol),
                  _detailChip('Type', investment.type.name.toUpperCase()),
                  _detailChip('Quantity', investment.quantity.toString()),
                  _detailChip(
                    'Purchase',
                    '₹${investment.purchasePrice.toStringAsFixed(2)}',
                  ),
                  _detailChip(
                    'Current',
                    '₹${investment.currentPrice.toStringAsFixed(2)}',
                  ),
                  _detailChip(
                    'Invested',
                    '₹${investment.totalCost.toStringAsFixed(0)}',
                  ),
                  _detailChip(
                    'Value',
                    '₹${investment.totalValue.toStringAsFixed(0)}',
                  ),
                  _detailChip(
                    isProfit ? 'Profit' : 'Loss',
                    '${isProfit ? '+' : ''}₹${investment.profit.toStringAsFixed(0)} (${investment.profitPercentage.toStringAsFixed(1)}%)',
                    color: profitColor,
                  ),
                  _detailChip(
                    'Held',
                    '${DateTime.now().difference(investment.purchaseDate).inDays} days',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmDelete(investment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Investment'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailChip(String label, String value, {Color? color}) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _confirmDelete(Investment investment) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Investment'),
            content: Text('Delete ${investment.name}? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) _deleteInvestment(investment.id);
  }

  void _deleteInvestment(String id) {
    setState(() => _investments.removeWhere((inv) => inv.id == id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Investment deleted')));
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Portfolio Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticsRow('Diversification Score', '8.2/10', Colors.green),
            _buildAnalyticsRow('Risk Level', 'Moderate', Colors.orange),
            _buildAnalyticsRow(
              'Best Performer',
              'Bitcoin (+14.5%)',
              Colors.green,
            ),
            _buildAnalyticsRow('Total Dividend', '₹2,340', Colors.blue),
            _buildAnalyticsRow('Portfolio Beta', '1.15', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

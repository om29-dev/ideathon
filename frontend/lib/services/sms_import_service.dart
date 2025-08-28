import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';

/// Service to import SMS messages (Android only) and extract expense transactions.
class SmsImportService {
  static const MethodChannel _smsChannel = MethodChannel('app/sms');

  /// Attempts to read SMS inbox and convert expense-related messages
  /// into Transaction objects.
  /// Returns list of extracted transactions.
  static Future<List<Transaction>> importExpenseTransactions() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('SMS import is only supported on Android');
    }

    // Request SMS permission if not granted
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      throw Exception('SMS permission denied');
    }

    final raw = await _smsChannel.invokeMethod('getSms');
    if (raw is! List) return [];

    final List<Transaction> transactions = [];
    final now = DateTime.now();

    int counter = 0;
    for (final item in raw) {
      if (item is Map) {
        final body = (item['body'] ?? '').toString();
        final dateMillis =
            int.tryParse('${item['date'] ?? ''}') ?? now.millisecondsSinceEpoch;
        final dt = DateTime.fromMillisecondsSinceEpoch(
          dateMillis,
          isUtc: false,
        );

        final extracted = _extractExpensesFromBody(body, dt);
        for (final e in extracted) {
          transactions.add(
            e.copyWith(id: 'sms_${dt.millisecondsSinceEpoch}_${counter++}'),
          );
        }
      }
    }
    return transactions;
  }

  /// Extracts expense data from a single SMS body.
  static List<Transaction> _extractExpensesFromBody(
    String body,
    DateTime date,
  ) {
    final List<Transaction> results = [];
    final lower = body.toLowerCase();

    // Heuristic: consider only debits / spends
    final isDebit =
        lower.contains('debited') ||
        lower.contains('spent') ||
        lower.contains('purchase') ||
        lower.contains('txn') ||
        lower.contains('transaction');
    if (!isDebit) return results; // skip credit-only notifications

    // Amount regex (₹123.45 / INR 1,234 / Rs.500)
    final amountRegex = RegExp(
      r'(?:inr|rs\.?|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return results;
    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    if (amount == null) return results;

    final merchant = _extractMerchant(body) ?? 'Expense';
    final category = _categorize(merchant, lower);

    results.add(
      Transaction(
        id: '', // temp, replaced by caller
        title: merchant,
        amount: amount,
        date: date,
        type: TransactionType.expense,
        category: category,
        description: body.length > 120 ? body.substring(0, 120) + '...' : body,
      ),
    );
    return results;
  }

  static String? _extractMerchant(String body) {
    // Simple pattern after 'at', 'to', 'in'
    final merchantRegex = RegExp(r'(?:at|to|in)\s+([A-Za-z0-9&._\- ]{2,30})');
    final m = merchantRegex.firstMatch(body);
    if (m != null) {
      return m.group(1)!.trim();
    }
    return null;
  }

  static String _categorize(String merchant, String lowerBody) {
    final mLower = merchant.toLowerCase();
    bool any(List<String> words) =>
        words.any((w) => mLower.contains(w) || lowerBody.contains(w));
    if (any(['uber', 'ola', 'rapido', 'metro', 'bus', 'cab', 'train']))
      return 'Transport';
    if (any([
      'coffee',
      'cafe',
      'restaurant',
      'pizza',
      'food',
      'swiggy',
      'zomato',
    ]))
      return 'Food';
    if (any(['netflix', 'prime', 'spotify', 'movie'])) return 'Entertainment';
    if (any(['pharma', 'chemist', 'medical', 'hospital'])) return 'Healthcare';
    if (any(['amazon', 'flipkart', 'myntra', 'store', 'bazaar']))
      return 'Shopping';
    if (any(['electricity', 'dth', 'bill', 'recharge'])) return 'Bills';
    return 'Other';
  }
}

extension _TransactionCopy on Transaction {
  Transaction copyWith({String? id}) => Transaction(
    id: id ?? this.id,
    title: title,
    amount: amount,
    date: date,
    type: type,
    category: category,
    description: description,
    location: location,
    imageUrl: imageUrl,
  );
}

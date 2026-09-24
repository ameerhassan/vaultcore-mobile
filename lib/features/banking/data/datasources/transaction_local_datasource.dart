import 'package:flutter_enterprise_clean_architecture/features/banking/data/models/transaction_model.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getCachedTransactions();
  Future<void> cacheTransactions(List<TransactionModel> transactions);
  Future<void> savePendingTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getPendingTransactions();
  Future<void> markTransactionSynced(String id);
  Future<double> getCachedBalance();
  Future<void> updateCachedBalance(double balance);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final List<TransactionModel> _cachedStore = [
    TransactionModel(
      id: 'tx_init_101',
      title: 'Salary Deposit - Emirates NBD',
      amount: 18500.0,
      currency: 'AED',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-DXB-984321',
    ),
    TransactionModel(
      id: 'tx_init_102',
      title: 'Sharjah Real Estate Lease',
      amount: 4200.0,
      currency: 'AED',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.debit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-SHJ-110293',
    ),
    TransactionModel(
      id: 'tx_init_103',
      title: 'DEWA Utility Bill Payment',
      amount: 680.0,
      currency: 'AED',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.debit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-DXB-554210',
    ),
  ];

  double _currentBalance = 13620.0;

  @override
  Future<List<TransactionModel>> getCachedTransactions() async {
    return List.unmodifiable(_cachedStore);
  }

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    _cachedStore.clear();
    _cachedStore.addAll(transactions);
  }

  @override
  Future<void> savePendingTransaction(TransactionModel transaction) async {
    _cachedStore.insert(0, transaction);
  }

  @override
  Future<List<TransactionModel>> getPendingTransactions() async {
    return _cachedStore.where((tx) => tx.status == TransactionStatus.pendingSync).toList();
  }

  @override
  Future<void> markTransactionSynced(String id) async {
    final index = _cachedStore.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      final old = _cachedStore[index];
      _cachedStore[index] = TransactionModel(
        id: old.id,
        title: old.title,
        amount: old.amount,
        currency: old.currency,
        timestamp: old.timestamp,
        type: old.type,
        status: TransactionStatus.completed,
        referenceNumber: old.referenceNumber,
      );
    }
  }

  @override
  Future<double> getCachedBalance() async => _currentBalance;

  @override
  Future<void> updateCachedBalance(double balance) async {
    _currentBalance = balance;
  }
}

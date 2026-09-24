import 'package:flutter_enterprise_clean_architecture/features/banking/data/models/transaction_model.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:uuid/uuid.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> fetchRemoteTransactions();
  Future<TransactionModel> executeRemoteTransfer({
    required String recipient,
    required double amount,
    required String note,
  });
  Future<bool> pushSyncedTransaction(TransactionModel transaction);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Uuid uuid;
  TransactionRemoteDataSourceImpl({Uuid? uuid}) : uuid = uuid ?? const Uuid();

  @override
  Future<List<TransactionModel>> fetchRemoteTransactions() async {
    // Simulated remote banking microservice network latency
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      TransactionModel(
        id: 'tx_rem_901',
        title: 'Salary Deposit - Emirates NBD',
        amount: 18500.0,
        currency: 'AED',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        referenceNumber: 'REF-DXB-984321',
      ),
      TransactionModel(
        id: 'tx_rem_902',
        title: 'Sharjah Real Estate Lease',
        amount: 4200.0,
        currency: 'AED',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        referenceNumber: 'REF-SHJ-110293',
      ),
      TransactionModel(
        id: 'tx_rem_903',
        title: 'DEWA Utility Bill Payment',
        amount: 680.0,
        currency: 'AED',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        referenceNumber: 'REF-DXB-554210',
      ),
    ];
  }

  @override
  Future<TransactionModel> executeRemoteTransfer({
    required String recipient,
    required double amount,
    required String note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return TransactionModel(
      id: 'tx_srv_${uuid.v4().substring(0, 8)}',
      title: 'Transfer to $recipient ($note)',
      amount: amount,
      currency: 'AED',
      timestamp: DateTime.now(),
      type: TransactionType.debit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-UAE-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );
  }

  @override
  Future<bool> pushSyncedTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return true;
  }
}

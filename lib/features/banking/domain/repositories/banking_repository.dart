import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/account_balance_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';

abstract class BankingRepository {
  Future<Result<List<TransactionEntity>>> getTransactions({bool forceRefresh = false});
  Future<Result<AccountBalanceEntity>> getAccountBalance();
  Future<Result<TransactionEntity>> createTransfer({
    required String recipient,
    required double amount,
    required String note,
  });
  Future<Result<int>> syncPendingTransactions();
}

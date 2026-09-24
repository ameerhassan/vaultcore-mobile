import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';

class SyncPendingTransactionsUseCase {
  final BankingRepository repository;

  const SyncPendingTransactionsUseCase(this.repository);

  Future<Result<int>> call() {
    return repository.syncPendingTransactions();
  }
}

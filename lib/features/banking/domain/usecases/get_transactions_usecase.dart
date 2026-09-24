import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';

class GetTransactionsUseCase {
  final BankingRepository repository;

  const GetTransactionsUseCase(this.repository);

  Future<Result<List<TransactionEntity>>> call({bool forceRefresh = false}) {
    return repository.getTransactions(forceRefresh: forceRefresh);
  }
}

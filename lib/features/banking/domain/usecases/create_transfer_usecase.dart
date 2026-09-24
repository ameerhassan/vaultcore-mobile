import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';

class CreateTransferUseCase {
  final BankingRepository repository;

  const CreateTransferUseCase(this.repository);

  Future<Result<TransactionEntity>> call({
    required String recipient,
    required double amount,
    required String note,
  }) {
    return repository.createTransfer(
      recipient: recipient,
      amount: amount,
      note: note,
    );
  }
}

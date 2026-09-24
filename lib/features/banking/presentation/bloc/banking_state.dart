import 'package:equatable/equatable.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/account_balance_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';

enum BankingStatus { initial, loading, loaded, transferring, syncInProgress, failure }

class BankingState extends Equatable {
  final BankingStatus status;
  final AccountBalanceEntity? accountBalance;
  final List<TransactionEntity> transactions;
  final String? errorMessage;
  final String? successMessage;
  final bool isOnline;

  const BankingState({
    this.status = BankingStatus.initial,
    this.accountBalance,
    this.transactions = const [],
    this.errorMessage,
    this.successMessage,
    this.isOnline = true,
  });

  bool get isLoading => status == BankingStatus.loading;
  bool get isTransferring => status == BankingStatus.transferring;
  bool get isSyncing => status == BankingStatus.syncInProgress;
  int get pendingSyncCount => transactions.where((tx) => tx.isPendingSync).length;

  BankingState copyWith({
    BankingStatus? status,
    AccountBalanceEntity? accountBalance,
    List<TransactionEntity>? transactions,
    String? errorMessage,
    String? successMessage,
    bool? isOnline,
  }) {
    return BankingState(
      status: status ?? this.status,
      accountBalance: accountBalance ?? this.accountBalance,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        accountBalance,
        transactions,
        errorMessage,
        successMessage,
        isOnline,
      ];
}

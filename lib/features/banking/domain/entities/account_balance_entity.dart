import 'package:equatable/equatable.dart';

class AccountBalanceEntity extends Equatable {
  final String accountNumber;
  final double balance;
  final String currency;
  final int pendingSyncCount;

  const AccountBalanceEntity({
    required this.accountNumber,
    required this.balance,
    this.currency = 'AED',
    this.pendingSyncCount = 0,
  });

  @override
  List<Object?> get props => [accountNumber, balance, currency, pendingSyncCount];
}

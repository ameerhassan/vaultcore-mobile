import 'package:equatable/equatable.dart';

abstract class BankingEvent extends Equatable {
  const BankingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankingOverviewEvent extends BankingEvent {
  final bool forceRefresh;
  const LoadBankingOverviewEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SubmitFundTransferEvent extends BankingEvent {
  final String recipient;
  final double amount;
  final String note;

  const SubmitFundTransferEvent({
    required this.recipient,
    required this.amount,
    required this.note,
  });

  @override
  List<Object?> get props => [recipient, amount, note];
}

class TriggerOfflineSyncEvent extends BankingEvent {
  const TriggerOfflineSyncEvent();
}

class ToggleNetworkSimulationEvent extends BankingEvent {
  final bool isOnline;
  const ToggleNetworkSimulationEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

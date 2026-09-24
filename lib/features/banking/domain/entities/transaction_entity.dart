import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }
enum TransactionStatus { completed, pendingSync, failed }

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final TransactionType type;
  final TransactionStatus status;
  final String referenceNumber;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    this.currency = 'AED',
    required this.timestamp,
    required this.type,
    required this.status,
    required this.referenceNumber,
  });

  bool get isPendingSync => status == TransactionStatus.pendingSync;

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    DateTime? timestamp,
    TransactionType? type,
    TransactionStatus? status,
    String? referenceNumber,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, currency, timestamp, type, status, referenceNumber];
}

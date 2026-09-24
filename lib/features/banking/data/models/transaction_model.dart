import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    super.currency = 'AED',
    required super.timestamp,
    required super.type,
    required super.status,
    required super.referenceNumber,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'AED',
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
      status: switch (json['status']) {
        'pendingSync' => TransactionStatus.pendingSync,
        'failed' => TransactionStatus.failed,
        _ => TransactionStatus.completed,
      },
      referenceNumber: json['referenceNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'status': switch (status) {
        TransactionStatus.pendingSync => 'pendingSync',
        TransactionStatus.failed => 'failed',
        TransactionStatus.completed => 'completed',
      },
      'referenceNumber': referenceNumber,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      currency: entity.currency,
      timestamp: entity.timestamp,
      type: entity.type,
      status: entity.status,
      referenceNumber: entity.referenceNumber,
    );
  }
}

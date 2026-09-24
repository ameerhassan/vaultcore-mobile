import 'package:flutter/material.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final isPending = transaction.isPendingSync;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? const Color(0xFFECFDF5)
              : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9)),
          child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : (isPending ? Icons.sync_problem_rounded : Icons.arrow_upward_rounded),
            color: isCredit
                ? const Color(0xFF047857)
                : (isPending ? const Color(0xFFD97706) : const Color(0xFF1E293B)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPending)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'OFFLINE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${transaction.referenceNumber} • ${transaction.timestamp.toLocal().toString().substring(0, 16)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ),
        trailing: Text(
          '${isCredit ? "+" : "-"} ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isCredit ? const Color(0xFF047857) : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

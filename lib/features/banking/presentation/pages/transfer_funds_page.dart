import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_event.dart';

class TransferFundsPage extends StatefulWidget {
  const TransferFundsPage({super.key});

  @override
  State<TransferFundsPage> createState() => _TransferFundsPageState();
}

class _TransferFundsPageState extends State<TransferFundsPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      context.read<BankingBloc>().add(
            SubmitFundTransferEvent(
              recipient: _recipientController.text.trim(),
              amount: amount,
              note: _noteController.text.trim(),
            ),
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Instant Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recipient Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Recipient Name or IBAN',
                  hintText: 'e.g. Fatima Al Zahra / AE02 033...',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please specify recipient' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (AED)',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please specify transfer amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Transfer Purpose / Note',
                  hintText: 'e.g. Invoice settlement, family allowance',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please specify purpose' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.security, size: 18),
                label: const Text('Authorize & Send (Biometric Protected)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

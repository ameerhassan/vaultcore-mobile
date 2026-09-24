import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_event.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_state.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/pages/transfer_funds_page.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/widgets/balance_card.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/widgets/offline_sync_banner.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/widgets/transaction_card.dart';

class BankingDashboardPage extends StatefulWidget {
  const BankingDashboardPage({super.key});

  @override
  State<BankingDashboardPage> createState() => _BankingDashboardPageState();
}

class _BankingDashboardPageState extends State<BankingDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<BankingBloc>().add(const LoadBankingOverviewEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EMIRATES ISLAMIC BANK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            Text('Enterprise Mobile Banking Core', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          BlocBuilder<BankingBloc, BankingState>(
            builder: (context, state) {
              return IconButton(
                tooltip: state.isOnline ? 'Switch to Offline Mode' : 'Switch to Online Mode',
                icon: Icon(
                  state.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: state.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
                onPressed: () {
                  context.read<BankingBloc>().add(ToggleNetworkSimulationEvent(!state.isOnline));
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Ledger',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BankingBloc>().add(const LoadBankingOverviewEvent(forceRefresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<BankingBloc, BankingState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade800,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF047857),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BankingBloc>().add(const LoadBankingOverviewEvent(forceRefresh: true));
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                BalanceCard(
                  balance: state.accountBalance,
                  onTransferPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<BankingBloc>(),
                          child: const TransferFundsPage(),
                        ),
                      ),
                    );
                  },
                ),
                OfflineSyncBanner(
                  pendingCount: state.pendingSyncCount,
                  isSyncing: state.isSyncing,
                  onSyncPressed: () {
                    context.read<BankingBloc>().add(const TriggerOfflineSyncEvent());
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Verified Audit Log',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (state.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No transactions recorded in local encrypted store.'),
                    ),
                  )
                else
                  ...state.transactions.map((tx) => TransactionCard(transaction: tx)),
              ],
            ),
          );
        },
      ),
    );
  }
}

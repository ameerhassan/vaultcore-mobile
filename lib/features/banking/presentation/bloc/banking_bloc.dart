import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/network_info.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/account_balance_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/create_transfer_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/sync_pending_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_event.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_state.dart';

class BankingBloc extends Bloc<BankingEvent, BankingState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final CreateTransferUseCase createTransferUseCase;
  final SyncPendingTransactionsUseCase syncPendingTransactionsUseCase;
  final BankingRepository bankingRepository;
  final NetworkInfo networkInfo;

  BankingBloc({
    required this.getTransactionsUseCase,
    required this.createTransferUseCase,
    required this.syncPendingTransactionsUseCase,
    required this.bankingRepository,
    required this.networkInfo,
  }) : super(const BankingState()) {
    on<LoadBankingOverviewEvent>(_onLoadBankingOverview);
    on<SubmitFundTransferEvent>(_onSubmitFundTransfer);
    on<TriggerOfflineSyncEvent>(_onTriggerOfflineSync);
    on<ToggleNetworkSimulationEvent>(_onToggleNetworkSimulation);
  }

  Future<void> _onLoadBankingOverview(
    LoadBankingOverviewEvent event,
    Emitter<BankingState> emit,
  ) async {
    emit(state.copyWith(status: BankingStatus.loading));

    final balanceResult = await bankingRepository.getAccountBalance();
    final txResult = await getTransactionsUseCase(forceRefresh: event.forceRefresh);

    if (txResult.isSuccess && balanceResult.isSuccess) {
      emit(state.copyWith(
        status: BankingStatus.loaded,
        accountBalance: balanceResult.dataOrNull,
        transactions: txResult.dataOrNull ?? [],
        errorMessage: null,
      ));
    } else {
      final failure = txResult.failureOrNull ?? balanceResult.failureOrNull;
      emit(state.copyWith(
        status: BankingStatus.failure,
        errorMessage: failure?.message ?? 'Failed to load banking data',
      ));
    }
  }

  Future<void> _onSubmitFundTransfer(
    SubmitFundTransferEvent event,
    Emitter<BankingState> emit,
  ) async {
    emit(state.copyWith(status: BankingStatus.transferring));

    final result = await createTransferUseCase(
      recipient: event.recipient,
      amount: event.amount,
      note: event.note,
    );

    await result.fold(
      onFailure: (failure) async {
        emit(state.copyWith(
          status: BankingStatus.failure,
          errorMessage: failure.message,
        ));
      },
      onSuccess: (newTx) async {
        final updatedTxList = [newTx, ...state.transactions];
        final currentBal = state.accountBalance?.balance ?? 0.0;
        final newBal = currentBal - event.amount;

        final updatedAccount = state.accountBalance != null
            ? AccountBalanceEntity(
                accountNumber: state.accountBalance!.accountNumber,
                balance: newBal,
                currency: state.accountBalance!.currency,
                pendingSyncCount: updatedTxList.where((tx) => tx.isPendingSync).length,
              )
            : null;

        emit(state.copyWith(
          status: BankingStatus.loaded,
          transactions: updatedTxList,
          accountBalance: updatedAccount,
          successMessage: newTx.isPendingSync
              ? 'Device is offline. Transfer queued securely for background sync!'
              : 'Transfer of AED ${event.amount.toStringAsFixed(2)} completed successfully!',
        ));
      },
    );
  }

  Future<void> _onTriggerOfflineSync(
    TriggerOfflineSyncEvent event,
    Emitter<BankingState> emit,
  ) async {
    if (state.pendingSyncCount == 0) return;

    emit(state.copyWith(status: BankingStatus.syncInProgress));

    final result = await syncPendingTransactionsUseCase();

    await result.fold(
      onFailure: (failure) async {
        emit(state.copyWith(
          status: BankingStatus.failure,
          errorMessage: failure.message,
        ));
      },
      onSuccess: (count) async {
        add(const LoadBankingOverviewEvent(forceRefresh: true));
        emit(state.copyWith(
          successMessage: 'Successfully synced $count offline transaction(s) with banking gateway!',
        ));
      },
    );
  }

  void _onToggleNetworkSimulation(
    ToggleNetworkSimulationEvent event,
    Emitter<BankingState> emit,
  ) {
    emit(state.copyWith(
      isOnline: event.isOnline,
      successMessage: event.isOnline
          ? 'Network mode: ONLINE (Direct Cloud Sync)'
          : 'Network mode: OFFLINE SIMULATION (Optimistic Local Queue Active)',
    ));
  }
}

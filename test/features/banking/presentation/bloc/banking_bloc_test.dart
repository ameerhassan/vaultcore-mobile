import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/network_info.dart';
import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/account_balance_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/create_transfer_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/sync_pending_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_event.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTransactionsUseCase extends Mock implements GetTransactionsUseCase {}
class MockCreateTransferUseCase extends Mock implements CreateTransferUseCase {}
class MockSyncPendingTransactionsUseCase extends Mock implements SyncPendingTransactionsUseCase {}
class MockBankingRepository extends Mock implements BankingRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;
  late MockCreateTransferUseCase mockCreateTransferUseCase;
  late MockSyncPendingTransactionsUseCase mockSyncPendingTransactionsUseCase;
  late MockBankingRepository mockBankingRepository;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    mockCreateTransferUseCase = MockCreateTransferUseCase();
    mockSyncPendingTransactionsUseCase = MockSyncPendingTransactionsUseCase();
    mockBankingRepository = MockBankingRepository();
    mockNetworkInfo = MockNetworkInfo();
  });

  BankingBloc buildBloc() {
    return BankingBloc(
      getTransactionsUseCase: mockGetTransactionsUseCase,
      createTransferUseCase: mockCreateTransferUseCase,
      syncPendingTransactionsUseCase: mockSyncPendingTransactionsUseCase,
      bankingRepository: mockBankingRepository,
      networkInfo: mockNetworkInfo,
    );
  }

  const testAccount = AccountBalanceEntity(
    accountNumber: 'AE02 0330 0000 1289 4410 01',
    balance: 10000.0,
    currency: 'AED',
    pendingSyncCount: 0,
  );

  final testTransactions = [
    TransactionEntity(
      id: 'tx_1',
      title: 'Consulting Settlement',
      amount: 4500.0,
      currency: 'AED',
      timestamp: DateTime(2026, 9, 21),
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-TX-1',
    ),
  ];

  test('initial state should have BankingStatus.initial and empty transactions', () {
    final bloc = buildBloc();
    expect(bloc.state.status, BankingStatus.initial);
    expect(bloc.state.transactions, isEmpty);
  });

  blocTest<BankingBloc, BankingState>(
    'emits [BankingStatus.loading, BankingStatus.loaded] when LoadBankingOverviewEvent succeeds',
    build: () {
      when(() => mockBankingRepository.getAccountBalance())
          .thenAnswer((_) async => const Success(testAccount));
      when(() => mockGetTransactionsUseCase(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Success(testTransactions));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadBankingOverviewEvent()),
    expect: () => [
      const BankingState(status: BankingStatus.loading),
      BankingState(
        status: BankingStatus.loaded,
        accountBalance: testAccount,
        transactions: testTransactions,
        errorMessage: null,
      ),
    ],
  );

  blocTest<BankingBloc, BankingState>(
    'emits [BankingStatus.transferring, BankingStatus.loaded] when transfer is completed',
    build: () {
      final newTx = TransactionEntity(
        id: 'tx_new_01',
        title: 'Transfer to Ahmad (Rent)',
        amount: 2500.0,
        currency: 'AED',
        timestamp: DateTime(2026, 9, 24),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        referenceNumber: 'REF-TRF-01',
      );

      when(() => mockCreateTransferUseCase(
            recipient: any(named: 'recipient'),
            amount: any(named: 'amount'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => Success(newTx));

      return buildBloc();
    },
    seed: () => BankingState(
      status: BankingStatus.loaded,
      accountBalance: testAccount,
      transactions: testTransactions,
    ),
    act: (bloc) => bloc.add(const SubmitFundTransferEvent(
      recipient: 'Ahmad',
      amount: 2500.0,
      note: 'Rent',
    )),
    expect: () => [
      BankingState(
        status: BankingStatus.transferring,
        accountBalance: testAccount,
        transactions: testTransactions,
      ),
      isA<BankingState>()
          .having((s) => s.status, 'status', BankingStatus.loaded)
          .having((s) => s.transactions.length, 'transactions count', 2)
          .having((s) => s.accountBalance?.balance, 'new balance', 7500.0)
          .having((s) => s.successMessage, 'success message', contains('completed successfully')),
    ],
  );
}

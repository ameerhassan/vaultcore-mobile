import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBankingRepository extends Mock implements BankingRepository {}

void main() {
  late GetTransactionsUseCase useCase;
  late MockBankingRepository mockRepository;

  setUp(() {
    mockRepository = MockBankingRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  final testTransactions = [
    TransactionEntity(
      id: 'tx_001',
      title: 'Salary Deposit',
      amount: 15000.0,
      currency: 'AED',
      timestamp: DateTime(2026, 9, 20),
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      referenceNumber: 'REF-001',
    ),
  ];

  test('should fetch transactions from banking repository successfully', () async {
    // Arrange
    when(() => mockRepository.getTransactions(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Success(testTransactions));

    // Act
    final result = await useCase(forceRefresh: true);

    // Assert
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, equals(testTransactions));
    verify(() => mockRepository.getTransactions(forceRefresh: true)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

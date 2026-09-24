import 'package:flutter_enterprise_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_enterprise_clean_architecture/core/error/failures.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/network_info.dart';
import 'package:flutter_enterprise_clean_architecture/core/utils/result.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/datasources/transaction_local_datasource.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/datasources/transaction_remote_datasource.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/models/transaction_model.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/account_balance_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/entities/transaction_entity.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';
import 'package:uuid/uuid.dart';

class BankingRepositoryImpl implements BankingRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  BankingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Result<List<TransactionEntity>>> getTransactions({bool forceRefresh = false}) async {
    try {
      final isOnline = await networkInfo.isConnected;

      if (isOnline && forceRefresh) {
        final remoteItems = await remoteDataSource.fetchRemoteTransactions();
        await localDataSource.cacheTransactions(remoteItems);
        return Success(remoteItems);
      } else {
        final cached = await localDataSource.getCachedTransactions();
        return Success(cached);
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AccountBalanceEntity>> getAccountBalance() async {
    try {
      final balance = await localDataSource.getCachedBalance();
      final pending = await localDataSource.getPendingTransactions();

      return Success(
        AccountBalanceEntity(
          accountNumber: 'AE02 0330 0000 1289 4410 01',
          balance: balance,
          currency: 'AED',
          pendingSyncCount: pending.length,
        ),
      );
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<TransactionEntity>> createTransfer({
    required String recipient,
    required double amount,
    required String note,
  }) async {
    try {
      final currentBalance = await localDataSource.getCachedBalance();
      if (currentBalance < amount) {
        return const Error(ServerFailure(message: 'Insufficient account balance for transfer.'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        // Direct remote API execution
        final completedTx = await remoteDataSource.executeRemoteTransfer(
          recipient: recipient,
          amount: amount,
          note: note,
        );
        await localDataSource.savePendingTransaction(completedTx);
        await localDataSource.updateCachedBalance(currentBalance - amount);
        return Success(completedTx);
      } else {
        // Offline-First Optimistic Execution: Queue for background sync
        final offlineTx = TransactionModel(
          id: 'tx_offline_${uuid.v4().substring(0, 8)}',
          title: 'Transfer to $recipient ($note)',
          amount: amount,
          currency: 'AED',
          timestamp: DateTime.now(),
          type: TransactionType.debit,
          status: TransactionStatus.pendingSync,
          referenceNumber: 'OFFLINE-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        );

        await localDataSource.savePendingTransaction(offlineTx);
        await localDataSource.updateCachedBalance(currentBalance - amount);
        return Success(offlineTx);
      }
    } catch (e) {
      return Error(ServerFailure(message: 'Transfer failed: $e'));
    }
  }

  @override
  Future<Result<int>> syncPendingTransactions() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Error(NetworkFailure(message: 'Cannot sync: Device remains offline.'));
      }

      final pending = await localDataSource.getPendingTransactions();
      int syncedCount = 0;

      for (final tx in pending) {
        final success = await remoteDataSource.pushSyncedTransaction(tx);
        if (success) {
          await localDataSource.markTransactionSynced(tx.id);
          syncedCount++;
        }
      }

      return Success(syncedCount);
    } catch (e) {
      return Error(ServerFailure(message: 'Sync failed: $e'));
    }
  }
}

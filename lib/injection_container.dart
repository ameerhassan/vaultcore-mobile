import 'package:flutter_enterprise_clean_architecture/core/network/api_client.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/auth_interceptor.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/network_info.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/datasources/transaction_local_datasource.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/datasources/transaction_remote_datasource.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/data/repositories/banking_repository_impl.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/repositories/banking_repository.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/create_transfer_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/domain/usecases/sync_pending_transactions_usecase.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. Core & Network Singletons
  sl.registerLazySingleton<TokenStorage>(() => InMemoryTokenStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(tokenStorage: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // 2. Data Sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(),
  );

  // 3. Repository
  sl.registerLazySingleton<BankingRepository>(
    () => BankingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 4. Use Cases
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateTransferUseCase(sl()));
  sl.registerLazySingleton(() => SyncPendingTransactionsUseCase(sl()));

  // 5. Presentation BLoC
  sl.registerFactory(
    () => BankingBloc(
      getTransactionsUseCase: sl(),
      createTransferUseCase: sl(),
      syncPendingTransactionsUseCase: sl(),
      bankingRepository: sl(),
      networkInfo: sl(),
    ),
  );
}

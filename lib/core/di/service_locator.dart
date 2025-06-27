import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/db_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/mock_bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/db_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/mock_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/db_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt serviceLocator = GetIt.instance;

// Используем это для переключения между моками и реальными репозиториями
const bool useMocks = false;

Future<void> setupServiceLocator() async {
  // Регистрируем сервисы
  serviceLocator.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);
  
  // Регистрируем репозитории
  if (useMocks) {
    // Мок-репозитории для разработки
    serviceLocator.registerLazySingleton<BankAccountRepository>(() => MockBankAccountRepository());
    serviceLocator.registerLazySingleton<CategoryRepository>(() => MockCategoryRepository());
    serviceLocator.registerLazySingleton<TransactionRepository>(() => MockTransactionRepository());
  } else {
    // Реальные репозитории с базой данных
    serviceLocator.registerLazySingleton<BankAccountRepository>(
      () => DbAccountRepository(databaseService: serviceLocator<DatabaseService>())
    );
    serviceLocator.registerLazySingleton<CategoryRepository>(
      () => DbCategoryRepository(databaseService: serviceLocator<DatabaseService>())
    );
    serviceLocator.registerLazySingleton<TransactionRepository>(
      () => DbTransactionRepository(databaseService: serviceLocator<DatabaseService>())
    );
  }
} 
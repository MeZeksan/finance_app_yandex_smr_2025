import 'package:get_it/get_it.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/backup_service.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';

// Mock repositories
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/mock_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/mock_bank_account_repository.dart';

// Network repositories
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/network_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/network_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/network_bank_account_repository.dart';

// Database repositories
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/db_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/db_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/db_account_repository.dart';

final GetIt sl = GetIt.instance;

/// Режимы работы приложения
enum AppMode {
  /// Только mock данные (для разработки)
  mock,
  /// Только локальная база данных (для тестирования)
  database,
  /// Полная версия с сетью (для продакшена)
  network,
}

class ServiceLocator {
  static bool _initialized = false;
  static AppMode _currentMode = AppMode.network;

  static AppMode get currentMode => _currentMode;

  /// Инициализация сервисов
  static Future<void> init({AppMode mode = AppMode.network}) async {
    if (_initialized) return;

    _currentMode = mode;

    // Регистрируем базовые сервисы
    await _registerCoreServices();
    
    // Регистрируем репозитории в зависимости от режима
    await _registerRepositories();

    _initialized = true;
  }

  /// Переключение режима работы (для тестирования)
  static Future<void> switchMode(AppMode mode) async {
    if (_currentMode == mode) return;

    _currentMode = mode;
    
    // Удаляем старые репозитории
    await _unregisterRepositories();
    
    // Регистрируем новые репозитории
    await _registerRepositories();
  }

  static Future<void> _registerCoreServices() async {
    // Инициализируем и регистрируем базовые сервисы
    final networkService = NetworkService();
    await networkService.initialize();
    sl.registerSingleton<NetworkService>(networkService);

    // Регистрируем DatabaseService только если используется
    if (_currentMode == AppMode.database || _currentMode == AppMode.network) {
      final databaseService = DatabaseService.instance;
      await databaseService.initialize();
      sl.registerSingleton<DatabaseService>(databaseService);
    }

    // Регистрируем BackupService только для network режима
    if (_currentMode == AppMode.network) {
      sl.registerSingleton<BackupService>(BackupService());
    }
  }

  static Future<void> _registerRepositories() async {
    switch (_currentMode) {
      case AppMode.mock:
        _registerMockRepositories();
        break;
      case AppMode.database:
        _registerDatabaseRepositories();
        break;
      case AppMode.network:
        _registerNetworkRepositories();
        break;
    }
  }

  static void _registerMockRepositories() {
    sl.registerSingleton<TransactionRepository>(MockTransactionRepository());
    sl.registerSingleton<CategoryRepository>(MockCategoryRepository());
    sl.registerSingleton<BankAccountRepository>(MockBankAccountRepository());
  }

  static void _registerDatabaseRepositories() {
    final databaseService = sl<DatabaseService>();
    sl.registerSingleton<TransactionRepository>(
      DbTransactionRepository(databaseService: databaseService),
    );
    sl.registerSingleton<CategoryRepository>(
      DbCategoryRepository(databaseService: databaseService),
    );
    sl.registerSingleton<BankAccountRepository>(
      DbAccountRepository(databaseService: databaseService),
    );
  }

  static void _registerNetworkRepositories() {
    sl.registerSingleton<TransactionRepository>(NetworkTransactionRepository());
    sl.registerSingleton<CategoryRepository>(NetworkCategoryRepository());
    sl.registerSingleton<BankAccountRepository>(NetworkBankAccountRepository());
  }

  static Future<void> _unregisterRepositories() async {
    if (sl.isRegistered<TransactionRepository>()) {
      sl.unregister<TransactionRepository>();
    }
    if (sl.isRegistered<CategoryRepository>()) {
      sl.unregister<CategoryRepository>();
    }
    if (sl.isRegistered<BankAccountRepository>()) {
      sl.unregister<BankAccountRepository>();
    }
  }

  /// Очистка всех зависимостей
  static Future<void> dispose() async {
    await _unregisterRepositories();
    
    if (sl.isRegistered<BackupService>()) {
      sl.unregister<BackupService>();
    }
    
    if (sl.isRegistered<DatabaseService>()) {
      sl.unregister<DatabaseService>();
    }
    
    if (sl.isRegistered<NetworkService>()) {
      sl<NetworkService>().dispose();
      sl.unregister<NetworkService>();
    }
    
    _initialized = false;
  }

  /// Получение репозитория транзакций
  static TransactionRepository get transactionRepository => sl<TransactionRepository>();

  /// Получение репозитория категорий
  static CategoryRepository get categoryRepository => sl<CategoryRepository>();

  /// Получение репозитория аккаунтов
  static BankAccountRepository get bankAccountRepository => sl<BankAccountRepository>();

  /// Получение сервиса сети
  static NetworkService get networkService => sl<NetworkService>();

  /// Получение сервиса базы данных (если доступен)
  static DatabaseService? get databaseService => 
    sl.isRegistered<DatabaseService>() ? sl<DatabaseService>() : null;

  /// Получение сервиса бэкапа (если доступен)
  static BackupService? get backupService => 
    sl.isRegistered<BackupService>() ? sl<BackupService>() : null;
} 
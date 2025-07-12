import 'package:finance_app_yandex_smr_2025/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/account_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/transaction_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store _store;
  
  /// Getter для доступа к store из других классов
  Store get store => _store;

  /// A Box of Account entities.
  late final Box<AccountEntity> accountBox;

  /// A Box of Category entities.
  late final Box<CategoryEntity> categoryBox;

  /// A Box of Transaction entities.
  late final Box<TransactionEntity> transactionBox;

  /// A Box of Backup Operation entities.
  late final Box<BackupOperationEntity> backupOperationBox;

  ObjectBox._create(this._store) {
    accountBox = Box<AccountEntity>(_store);
    categoryBox = Box<CategoryEntity>(_store);
    transactionBox = Box<TransactionEntity>(_store);
    backupOperationBox = Box<BackupOperationEntity>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "finance-app-db"));
    return ObjectBox._create(store);
  }

  /// Closes the underlying database.
  void close() {
    _store.close();
  }
} 
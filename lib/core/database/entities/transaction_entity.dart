import 'package:objectbox/objectbox.dart';
import 'account_entity.dart';
import 'category_entity.dart';

@Entity()
class TransactionEntity {
  @Id()
  int id;
  
  final ToOne<AccountEntity> account = ToOne<AccountEntity>();
  final ToOne<CategoryEntity> category = ToOne<CategoryEntity>();
  
  String amount;
  DateTime transactionDate;
  String? comment;
  DateTime createdAt;
  DateTime updatedAt;

  TransactionEntity({
    this.id = 0,
    required this.amount,
    required this.transactionDate,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Вспомогательные геттеры для обратной совместимости
  int get accountId => account.targetId;
  set accountId(int id) => account.targetId = id;
  
  int get categoryId => category.targetId;
  set categoryId(int id) => category.targetId = id;
} 
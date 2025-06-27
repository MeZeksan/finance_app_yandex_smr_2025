import 'package:objectbox/objectbox.dart';
import 'account_entity.dart';
import 'category_entity.dart';

@Entity()
class TransactionEntity {
  @Id()
  int id;
  
  final ToOne<AccountEntity> account = ToOne<AccountEntity>();
  final ToOne<CategoryEntity> category = ToOne<CategoryEntity>();
  
  int accountId;
  int categoryId;
  String amount;
  DateTime transactionDate;
  String? comment;
  DateTime createdAt;
  DateTime updatedAt;

  TransactionEntity({
    this.id = 0,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });
} 
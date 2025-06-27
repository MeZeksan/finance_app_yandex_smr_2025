import 'package:objectbox/objectbox.dart';

@Entity()
class CategoryEntity {
  @Id()
  int id;
  
  String name;
  String emoji;
  bool isIncome;
  DateTime createdAt;
  DateTime updatedAt;

  CategoryEntity({
    this.id = 0,
    required this.name,
    required this.emoji,
    required this.isIncome,
    required this.createdAt,
    required this.updatedAt,
  });
} 
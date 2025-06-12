// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_responce.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountResponce _$AccountResponceFromJson(Map<String, dynamic> json) =>
    _AccountResponce(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      balance: json['balance'] as String,
      currency: json['currency'] as String,
      incomeStats:
          StatItem.fromJson(json['incomeStats'] as Map<String, dynamic>),
      expenseStats:
          StatItem.fromJson(json['expenseStats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AccountResponceToJson(_AccountResponce instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
      'incomeStats': instance.incomeStats,
      'expenseStats': instance.expenseStats,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

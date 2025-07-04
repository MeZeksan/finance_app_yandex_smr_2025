// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BalanceData _$BalanceDataFromJson(Map<String, dynamic> json) => _BalanceData(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$BalanceDataToJson(_BalanceData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'type': instance.type,
    };

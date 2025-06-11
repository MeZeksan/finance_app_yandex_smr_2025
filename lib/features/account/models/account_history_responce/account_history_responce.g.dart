// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_responce.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountHistoryResponce _$AccountHistoryResponceFromJson(
        Map<String, dynamic> json) =>
    _AccountHistoryResponce(
      accountId: (json['accountId'] as num).toInt(),
      accountName: json['accountName'] as String,
      currency: json['currency'] as String,
      currentBalance: json['currentBalance'] as String,
      history: AccountHistory.fromJson(json['history'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AccountHistoryResponceToJson(
        _AccountHistoryResponce instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'currency': instance.currency,
      'currentBalance': instance.currentBalance,
      'history': instance.history,
    };

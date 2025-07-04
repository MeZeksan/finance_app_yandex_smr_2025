import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_data.freezed.dart';
part 'balance_data.g.dart';

@freezed
abstract class BalanceData with _$BalanceData {
  const factory BalanceData({
    required DateTime date,
    required double amount,
    required String type,
  }) = _BalanceData;

  factory BalanceData.fromJson(Map<String, dynamic> json) => _$BalanceDataFromJson(json);
} 
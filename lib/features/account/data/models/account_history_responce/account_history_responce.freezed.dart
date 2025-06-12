// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_history_responce.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountHistoryResponce {
  int get accountId; //1
  String get accountName; // основной счет
  String get currency; // USD
  String get currentBalance;
  AccountHistory get history;

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountHistoryResponceCopyWith<AccountHistoryResponce> get copyWith =>
      _$AccountHistoryResponceCopyWithImpl<AccountHistoryResponce>(
          this as AccountHistoryResponce, _$identity);

  /// Serializes this AccountHistoryResponce to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccountHistoryResponce &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.history, history) || other.history == history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, accountId, accountName, currency, currentBalance, history);

  @override
  String toString() {
    return 'AccountHistoryResponce(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
  }
}

/// @nodoc
abstract mixin class $AccountHistoryResponceCopyWith<$Res> {
  factory $AccountHistoryResponceCopyWith(AccountHistoryResponce value,
          $Res Function(AccountHistoryResponce) _then) =
      _$AccountHistoryResponceCopyWithImpl;
  @useResult
  $Res call(
      {int accountId,
      String accountName,
      String currency,
      String currentBalance,
      AccountHistory history});

  $AccountHistoryCopyWith<$Res> get history;
}

/// @nodoc
class _$AccountHistoryResponceCopyWithImpl<$Res>
    implements $AccountHistoryResponceCopyWith<$Res> {
  _$AccountHistoryResponceCopyWithImpl(this._self, this._then);

  final AccountHistoryResponce _self;
  final $Res Function(AccountHistoryResponce) _then;

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? accountName = null,
    Object? currency = null,
    Object? currentBalance = null,
    Object? history = null,
  }) {
    return _then(_self.copyWith(
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      accountName: null == accountName
          ? _self.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      currentBalance: null == currentBalance
          ? _self.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _self.history
          : history // ignore: cast_nullable_to_non_nullable
              as AccountHistory,
    ));
  }

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountHistoryCopyWith<$Res> get history {
    return $AccountHistoryCopyWith<$Res>(_self.history, (value) {
      return _then(_self.copyWith(history: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _AccountHistoryResponce implements AccountHistoryResponce {
  _AccountHistoryResponce(
      {required this.accountId,
      required this.accountName,
      required this.currency,
      required this.currentBalance,
      required this.history});
  factory _AccountHistoryResponce.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryResponceFromJson(json);

  @override
  final int accountId;
//1
  @override
  final String accountName;
// основной счет
  @override
  final String currency;
// USD
  @override
  final String currentBalance;
  @override
  final AccountHistory history;

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountHistoryResponceCopyWith<_AccountHistoryResponce> get copyWith =>
      __$AccountHistoryResponceCopyWithImpl<_AccountHistoryResponce>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AccountHistoryResponceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AccountHistoryResponce &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.history, history) || other.history == history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, accountId, accountName, currency, currentBalance, history);

  @override
  String toString() {
    return 'AccountHistoryResponce(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
  }
}

/// @nodoc
abstract mixin class _$AccountHistoryResponceCopyWith<$Res>
    implements $AccountHistoryResponceCopyWith<$Res> {
  factory _$AccountHistoryResponceCopyWith(_AccountHistoryResponce value,
          $Res Function(_AccountHistoryResponce) _then) =
      __$AccountHistoryResponceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int accountId,
      String accountName,
      String currency,
      String currentBalance,
      AccountHistory history});

  @override
  $AccountHistoryCopyWith<$Res> get history;
}

/// @nodoc
class __$AccountHistoryResponceCopyWithImpl<$Res>
    implements _$AccountHistoryResponceCopyWith<$Res> {
  __$AccountHistoryResponceCopyWithImpl(this._self, this._then);

  final _AccountHistoryResponce _self;
  final $Res Function(_AccountHistoryResponce) _then;

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accountId = null,
    Object? accountName = null,
    Object? currency = null,
    Object? currentBalance = null,
    Object? history = null,
  }) {
    return _then(_AccountHistoryResponce(
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      accountName: null == accountName
          ? _self.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      currentBalance: null == currentBalance
          ? _self.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _self.history
          : history // ignore: cast_nullable_to_non_nullable
              as AccountHistory,
    ));
  }

  /// Create a copy of AccountHistoryResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountHistoryCopyWith<$Res> get history {
    return $AccountHistoryCopyWith<$Res>(_self.history, (value) {
      return _then(_self.copyWith(history: value));
    });
  }
}

// dart format on

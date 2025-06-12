// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_responce.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountResponce {
  int get id; //1
  String get name; // основной счет
  String get balance; //1000.00
  String get currency; // RUB
  StatItem get incomeStats;
  StatItem get expenseStats;
  DateTime get createdAt; // дата
  DateTime get updatedAt;

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountResponceCopyWith<AccountResponce> get copyWith =>
      _$AccountResponceCopyWithImpl<AccountResponce>(
          this as AccountResponce, _$identity);

  /// Serializes this AccountResponce to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccountResponce &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.incomeStats, incomeStats) ||
                other.incomeStats == incomeStats) &&
            (identical(other.expenseStats, expenseStats) ||
                other.expenseStats == expenseStats) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, balance, currency,
      incomeStats, expenseStats, createdAt, updatedAt);

  @override
  String toString() {
    return 'AccountResponce(id: $id, name: $name, balance: $balance, currency: $currency, incomeStats: $incomeStats, expenseStats: $expenseStats, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AccountResponceCopyWith<$Res> {
  factory $AccountResponceCopyWith(
          AccountResponce value, $Res Function(AccountResponce) _then) =
      _$AccountResponceCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String balance,
      String currency,
      StatItem incomeStats,
      StatItem expenseStats,
      DateTime createdAt,
      DateTime updatedAt});

  $StatItemCopyWith<$Res> get incomeStats;
  $StatItemCopyWith<$Res> get expenseStats;
}

/// @nodoc
class _$AccountResponceCopyWithImpl<$Res>
    implements $AccountResponceCopyWith<$Res> {
  _$AccountResponceCopyWithImpl(this._self, this._then);

  final AccountResponce _self;
  final $Res Function(AccountResponce) _then;

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? balance = null,
    Object? currency = null,
    Object? incomeStats = null,
    Object? expenseStats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      incomeStats: null == incomeStats
          ? _self.incomeStats
          : incomeStats // ignore: cast_nullable_to_non_nullable
              as StatItem,
      expenseStats: null == expenseStats
          ? _self.expenseStats
          : expenseStats // ignore: cast_nullable_to_non_nullable
              as StatItem,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatItemCopyWith<$Res> get incomeStats {
    return $StatItemCopyWith<$Res>(_self.incomeStats, (value) {
      return _then(_self.copyWith(incomeStats: value));
    });
  }

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatItemCopyWith<$Res> get expenseStats {
    return $StatItemCopyWith<$Res>(_self.expenseStats, (value) {
      return _then(_self.copyWith(expenseStats: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _AccountResponce implements AccountResponce {
  _AccountResponce(
      {required this.id,
      required this.name,
      required this.balance,
      required this.currency,
      required this.incomeStats,
      required this.expenseStats,
      required this.createdAt,
      required this.updatedAt});
  factory _AccountResponce.fromJson(Map<String, dynamic> json) =>
      _$AccountResponceFromJson(json);

  @override
  final int id;
//1
  @override
  final String name;
// основной счет
  @override
  final String balance;
//1000.00
  @override
  final String currency;
// RUB
  @override
  final StatItem incomeStats;
  @override
  final StatItem expenseStats;
  @override
  final DateTime createdAt;
// дата
  @override
  final DateTime updatedAt;

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountResponceCopyWith<_AccountResponce> get copyWith =>
      __$AccountResponceCopyWithImpl<_AccountResponce>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AccountResponceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AccountResponce &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.incomeStats, incomeStats) ||
                other.incomeStats == incomeStats) &&
            (identical(other.expenseStats, expenseStats) ||
                other.expenseStats == expenseStats) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, balance, currency,
      incomeStats, expenseStats, createdAt, updatedAt);

  @override
  String toString() {
    return 'AccountResponce(id: $id, name: $name, balance: $balance, currency: $currency, incomeStats: $incomeStats, expenseStats: $expenseStats, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AccountResponceCopyWith<$Res>
    implements $AccountResponceCopyWith<$Res> {
  factory _$AccountResponceCopyWith(
          _AccountResponce value, $Res Function(_AccountResponce) _then) =
      __$AccountResponceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String balance,
      String currency,
      StatItem incomeStats,
      StatItem expenseStats,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $StatItemCopyWith<$Res> get incomeStats;
  @override
  $StatItemCopyWith<$Res> get expenseStats;
}

/// @nodoc
class __$AccountResponceCopyWithImpl<$Res>
    implements _$AccountResponceCopyWith<$Res> {
  __$AccountResponceCopyWithImpl(this._self, this._then);

  final _AccountResponce _self;
  final $Res Function(_AccountResponce) _then;

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? balance = null,
    Object? currency = null,
    Object? incomeStats = null,
    Object? expenseStats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_AccountResponce(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      incomeStats: null == incomeStats
          ? _self.incomeStats
          : incomeStats // ignore: cast_nullable_to_non_nullable
              as StatItem,
      expenseStats: null == expenseStats
          ? _self.expenseStats
          : expenseStats // ignore: cast_nullable_to_non_nullable
              as StatItem,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatItemCopyWith<$Res> get incomeStats {
    return $StatItemCopyWith<$Res>(_self.incomeStats, (value) {
      return _then(_self.copyWith(incomeStats: value));
    });
  }

  /// Create a copy of AccountResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatItemCopyWith<$Res> get expenseStats {
    return $StatItemCopyWith<$Res>(_self.expenseStats, (value) {
      return _then(_self.copyWith(expenseStats: value));
    });
  }
}

// dart format on

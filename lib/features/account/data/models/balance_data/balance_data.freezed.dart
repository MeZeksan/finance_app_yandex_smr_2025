// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'balance_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BalanceData {
  DateTime get date;
  double get amount;
  String get type;

  /// Create a copy of BalanceData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BalanceDataCopyWith<BalanceData> get copyWith =>
      _$BalanceDataCopyWithImpl<BalanceData>(this as BalanceData, _$identity);

  /// Serializes this BalanceData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BalanceData &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, amount, type);

  @override
  String toString() {
    return 'BalanceData(date: $date, amount: $amount, type: $type)';
  }
}

/// @nodoc
abstract mixin class $BalanceDataCopyWith<$Res> {
  factory $BalanceDataCopyWith(
          BalanceData value, $Res Function(BalanceData) _then) =
      _$BalanceDataCopyWithImpl;
  @useResult
  $Res call({DateTime date, double amount, String type});
}

/// @nodoc
class _$BalanceDataCopyWithImpl<$Res> implements $BalanceDataCopyWith<$Res> {
  _$BalanceDataCopyWithImpl(this._self, this._then);

  final BalanceData _self;
  final $Res Function(BalanceData) _then;

  /// Create a copy of BalanceData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? type = null,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _BalanceData implements BalanceData {
  const _BalanceData(
      {required this.date, required this.amount, required this.type});
  factory _BalanceData.fromJson(Map<String, dynamic> json) =>
      _$BalanceDataFromJson(json);

  @override
  final DateTime date;
  @override
  final double amount;
  @override
  final String type;

  /// Create a copy of BalanceData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BalanceDataCopyWith<_BalanceData> get copyWith =>
      __$BalanceDataCopyWithImpl<_BalanceData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BalanceDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BalanceData &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, amount, type);

  @override
  String toString() {
    return 'BalanceData(date: $date, amount: $amount, type: $type)';
  }
}

/// @nodoc
abstract mixin class _$BalanceDataCopyWith<$Res>
    implements $BalanceDataCopyWith<$Res> {
  factory _$BalanceDataCopyWith(
          _BalanceData value, $Res Function(_BalanceData) _then) =
      __$BalanceDataCopyWithImpl;
  @override
  @useResult
  $Res call({DateTime date, double amount, String type});
}

/// @nodoc
class __$BalanceDataCopyWithImpl<$Res> implements _$BalanceDataCopyWith<$Res> {
  __$BalanceDataCopyWithImpl(this._self, this._then);

  final _BalanceData _self;
  final $Res Function(_BalanceData) _then;

  /// Create a copy of BalanceData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? type = null,
  }) {
    return _then(_BalanceData(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

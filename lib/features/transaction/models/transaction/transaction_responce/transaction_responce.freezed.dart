// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_responce.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionResponce {
  int get id; //1
  AccountBrief get account;
  Category get category;
  String get amount; // 500.00
  DateTime get transactionDate;
  String? get comment; // может быть null, а так "Зарплата за месяц"
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransactionResponceCopyWith<TransactionResponce> get copyWith =>
      _$TransactionResponceCopyWithImpl<TransactionResponce>(
          this as TransactionResponce, _$identity);

  /// Serializes this TransactionResponce to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransactionResponce &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, account, category, amount,
      transactionDate, comment, createdAt, updatedAt);

  @override
  String toString() {
    return 'TransactionResponce(id: $id, account: $account, category: $category, amount: $amount, transactionDate: $transactionDate, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $TransactionResponceCopyWith<$Res> {
  factory $TransactionResponceCopyWith(
          TransactionResponce value, $Res Function(TransactionResponce) _then) =
      _$TransactionResponceCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      AccountBrief account,
      Category category,
      String amount,
      DateTime transactionDate,
      String? comment,
      DateTime createdAt,
      DateTime updatedAt});

  $AccountBriefCopyWith<$Res> get account;
  $CategoryCopyWith<$Res> get category;
}

/// @nodoc
class _$TransactionResponceCopyWithImpl<$Res>
    implements $TransactionResponceCopyWith<$Res> {
  _$TransactionResponceCopyWithImpl(this._self, this._then);

  final TransactionResponce _self;
  final $Res Function(TransactionResponce) _then;

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? account = null,
    Object? category = null,
    Object? amount = null,
    Object? transactionDate = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as AccountBrief,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDate: null == transactionDate
          ? _self.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountBriefCopyWith<$Res> get account {
    return $AccountBriefCopyWith<$Res>(_self.account, (value) {
      return _then(_self.copyWith(account: value));
    });
  }

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_self.category, (value) {
      return _then(_self.copyWith(category: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _TransactionResponce implements TransactionResponce {
  _TransactionResponce(
      {required this.id,
      required this.account,
      required this.category,
      required this.amount,
      required this.transactionDate,
      required this.comment,
      required this.createdAt,
      required this.updatedAt});
  factory _TransactionResponce.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponceFromJson(json);

  @override
  final int id;
//1
  @override
  final AccountBrief account;
  @override
  final Category category;
  @override
  final String amount;
// 500.00
  @override
  final DateTime transactionDate;
  @override
  final String? comment;
// может быть null, а так "Зарплата за месяц"
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransactionResponceCopyWith<_TransactionResponce> get copyWith =>
      __$TransactionResponceCopyWithImpl<_TransactionResponce>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TransactionResponceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransactionResponce &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, account, category, amount,
      transactionDate, comment, createdAt, updatedAt);

  @override
  String toString() {
    return 'TransactionResponce(id: $id, account: $account, category: $category, amount: $amount, transactionDate: $transactionDate, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$TransactionResponceCopyWith<$Res>
    implements $TransactionResponceCopyWith<$Res> {
  factory _$TransactionResponceCopyWith(_TransactionResponce value,
          $Res Function(_TransactionResponce) _then) =
      __$TransactionResponceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      AccountBrief account,
      Category category,
      String amount,
      DateTime transactionDate,
      String? comment,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $AccountBriefCopyWith<$Res> get account;
  @override
  $CategoryCopyWith<$Res> get category;
}

/// @nodoc
class __$TransactionResponceCopyWithImpl<$Res>
    implements _$TransactionResponceCopyWith<$Res> {
  __$TransactionResponceCopyWithImpl(this._self, this._then);

  final _TransactionResponce _self;
  final $Res Function(_TransactionResponce) _then;

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? account = null,
    Object? category = null,
    Object? amount = null,
    Object? transactionDate = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_TransactionResponce(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as AccountBrief,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDate: null == transactionDate
          ? _self.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountBriefCopyWith<$Res> get account {
    return $AccountBriefCopyWith<$Res>(_self.account, (value) {
      return _then(_self.copyWith(account: value));
    });
  }

  /// Create a copy of TransactionResponce
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_self.category, (value) {
      return _then(_self.copyWith(category: value));
    });
  }
}

// dart format on

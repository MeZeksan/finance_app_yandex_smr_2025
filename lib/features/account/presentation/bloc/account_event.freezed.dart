// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AccountEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccountEvent()';
  }
}

/// @nodoc
class $AccountEventCopyWith<$Res> {
  $AccountEventCopyWith(AccountEvent _, $Res Function(AccountEvent) __);
}

/// @nodoc

class _Started implements AccountEvent {
  const _Started();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccountEvent.started()';
  }
}

/// @nodoc

class _LoadAccount implements AccountEvent {
  const _LoadAccount({required this.accountId});

  final int accountId;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadAccountCopyWith<_LoadAccount> get copyWith =>
      __$LoadAccountCopyWithImpl<_LoadAccount>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoadAccount &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accountId);

  @override
  String toString() {
    return 'AccountEvent.loadAccount(accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$LoadAccountCopyWith<$Res>
    implements $AccountEventCopyWith<$Res> {
  factory _$LoadAccountCopyWith(
          _LoadAccount value, $Res Function(_LoadAccount) _then) =
      __$LoadAccountCopyWithImpl;
  @useResult
  $Res call({int accountId});
}

/// @nodoc
class __$LoadAccountCopyWithImpl<$Res> implements _$LoadAccountCopyWith<$Res> {
  __$LoadAccountCopyWithImpl(this._self, this._then);

  final _LoadAccount _self;
  final $Res Function(_LoadAccount) _then;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accountId = null,
  }) {
    return _then(_LoadAccount(
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _UpdateAccount implements AccountEvent {
  const _UpdateAccount({required this.accountId, required this.request});

  final int accountId;
  final AccountUpdateRequest request;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateAccountCopyWith<_UpdateAccount> get copyWith =>
      __$UpdateAccountCopyWithImpl<_UpdateAccount>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateAccount &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accountId, request);

  @override
  String toString() {
    return 'AccountEvent.updateAccount(accountId: $accountId, request: $request)';
  }
}

/// @nodoc
abstract mixin class _$UpdateAccountCopyWith<$Res>
    implements $AccountEventCopyWith<$Res> {
  factory _$UpdateAccountCopyWith(
          _UpdateAccount value, $Res Function(_UpdateAccount) _then) =
      __$UpdateAccountCopyWithImpl;
  @useResult
  $Res call({int accountId, AccountUpdateRequest request});

  $AccountUpdateRequestCopyWith<$Res> get request;
}

/// @nodoc
class __$UpdateAccountCopyWithImpl<$Res>
    implements _$UpdateAccountCopyWith<$Res> {
  __$UpdateAccountCopyWithImpl(this._self, this._then);

  final _UpdateAccount _self;
  final $Res Function(_UpdateAccount) _then;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accountId = null,
    Object? request = null,
  }) {
    return _then(_UpdateAccount(
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      request: null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as AccountUpdateRequest,
    ));
  }

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountUpdateRequestCopyWith<$Res> get request {
    return $AccountUpdateRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class _UpdateName implements AccountEvent {
  const _UpdateName(this.name);

  final String name;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateNameCopyWith<_UpdateName> get copyWith =>
      __$UpdateNameCopyWithImpl<_UpdateName>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateName &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() {
    return 'AccountEvent.updateName(name: $name)';
  }
}

/// @nodoc
abstract mixin class _$UpdateNameCopyWith<$Res>
    implements $AccountEventCopyWith<$Res> {
  factory _$UpdateNameCopyWith(
          _UpdateName value, $Res Function(_UpdateName) _then) =
      __$UpdateNameCopyWithImpl;
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$UpdateNameCopyWithImpl<$Res> implements _$UpdateNameCopyWith<$Res> {
  __$UpdateNameCopyWithImpl(this._self, this._then);

  final _UpdateName _self;
  final $Res Function(_UpdateName) _then;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
  }) {
    return _then(_UpdateName(
      null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _UpdateCurrency implements AccountEvent {
  const _UpdateCurrency(this.currency);

  final String currency;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateCurrencyCopyWith<_UpdateCurrency> get copyWith =>
      __$UpdateCurrencyCopyWithImpl<_UpdateCurrency>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateCurrency &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currency);

  @override
  String toString() {
    return 'AccountEvent.updateCurrency(currency: $currency)';
  }
}

/// @nodoc
abstract mixin class _$UpdateCurrencyCopyWith<$Res>
    implements $AccountEventCopyWith<$Res> {
  factory _$UpdateCurrencyCopyWith(
          _UpdateCurrency value, $Res Function(_UpdateCurrency) _then) =
      __$UpdateCurrencyCopyWithImpl;
  @useResult
  $Res call({String currency});
}

/// @nodoc
class __$UpdateCurrencyCopyWithImpl<$Res>
    implements _$UpdateCurrencyCopyWith<$Res> {
  __$UpdateCurrencyCopyWithImpl(this._self, this._then);

  final _UpdateCurrency _self;
  final $Res Function(_UpdateCurrency) _then;

  /// Create a copy of AccountEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currency = null,
  }) {
    return _then(_UpdateCurrency(
      null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

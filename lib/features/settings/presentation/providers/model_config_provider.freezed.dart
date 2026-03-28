// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_config_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModelConfig {

 String get provider; String get model;
/// Create a copy of ModelConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelConfigCopyWith<ModelConfig> get copyWith => _$ModelConfigCopyWithImpl<ModelConfig>(this as ModelConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelConfig&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,provider,model);

@override
String toString() {
  return 'ModelConfig(provider: $provider, model: $model)';
}


}

/// @nodoc
abstract mixin class $ModelConfigCopyWith<$Res>  {
  factory $ModelConfigCopyWith(ModelConfig value, $Res Function(ModelConfig) _then) = _$ModelConfigCopyWithImpl;
@useResult
$Res call({
 String provider, String model
});




}
/// @nodoc
class _$ModelConfigCopyWithImpl<$Res>
    implements $ModelConfigCopyWith<$Res> {
  _$ModelConfigCopyWithImpl(this._self, this._then);

  final ModelConfig _self;
  final $Res Function(ModelConfig) _then;

/// Create a copy of ModelConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? model = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelConfig].
extension ModelConfigPatterns on ModelConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelConfig value)  $default,){
final _that = this;
switch (_that) {
case _ModelConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ModelConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelConfig() when $default != null:
return $default(_that.provider,_that.model);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String model)  $default,) {final _that = this;
switch (_that) {
case _ModelConfig():
return $default(_that.provider,_that.model);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String model)?  $default,) {final _that = this;
switch (_that) {
case _ModelConfig() when $default != null:
return $default(_that.provider,_that.model);case _:
  return null;

}
}

}

/// @nodoc


class _ModelConfig implements ModelConfig {
  const _ModelConfig({this.provider = 'deepseek', this.model = 'deepseek-chat'});
  

@override@JsonKey() final  String provider;
@override@JsonKey() final  String model;

/// Create a copy of ModelConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelConfigCopyWith<_ModelConfig> get copyWith => __$ModelConfigCopyWithImpl<_ModelConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelConfig&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,provider,model);

@override
String toString() {
  return 'ModelConfig(provider: $provider, model: $model)';
}


}

/// @nodoc
abstract mixin class _$ModelConfigCopyWith<$Res> implements $ModelConfigCopyWith<$Res> {
  factory _$ModelConfigCopyWith(_ModelConfig value, $Res Function(_ModelConfig) _then) = __$ModelConfigCopyWithImpl;
@override @useResult
$Res call({
 String provider, String model
});




}
/// @nodoc
class __$ModelConfigCopyWithImpl<$Res>
    implements _$ModelConfigCopyWith<$Res> {
  __$ModelConfigCopyWithImpl(this._self, this._then);

  final _ModelConfig _self;
  final $Res Function(_ModelConfig) _then;

/// Create a copy of ModelConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? model = null,}) {
  return _then(_ModelConfig(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

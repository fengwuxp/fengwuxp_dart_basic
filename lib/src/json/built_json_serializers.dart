import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:fengwuxp_dart_basic/index.dart';
import 'package:fengwuxp_dart_basic/src/utils/string_utils.dart';

/// 基于 built_value的 json serializer
/// doc [https://github.com/google/built_value.dart]
class BuiltJsonSerializers {
  Serializers _serializers;

  BuiltJsonSerializers._(this._serializers);

  factory BuiltJsonSerializers(Serializers serializers) {
    return BuiltJsonSerializers._(serializers);
  }

  /// parse json [String] or [Map] or [List] or [Set] to object
  /// [source] type [String] or  [Map] or [List] or [Set]
  /// [serializer]  类型 serializer
  /// [formJson]    自定义的formJson 工厂方法
  /// [specifiedType]    FullType 存在泛型是需要
  /// 泛型支持需要 [SerializersBuilder.addBuilderFactory]
  T parseObject<T>(dynamic source, {Serializer<T> serializer, Function formJson, FullType specifiedType}) {
    if (_isEmpty(source)) {
      return null;
    }

    final json = _tryDecode(source);

    if (formJson != null) {
      // 自定义的fromJson方法
      return formJson(json);
    }

    if (serializer == null) {
      if (_isSpecifiedType(specifiedType)) {
        return this._serializers.deserialize(json, specifiedType: specifiedType);
      }
      return json;
    }

    // 需要使用泛型
    if (_isGeneric(serializer, specifiedType)) {
      return _deserializeWithGeneric(json, serializer, specifiedType);
    }

    return this._serializers.deserializeWith(serializer, json);
  }

  /// object to string
  /// [object] serialize object
  /// [serializer] built serializer
  /// [specifiedType]
  String toJson<T>(object, {Serializer<T> serializer, FullType specifiedType}) {
    if (_isEmpty(object)) {
      return null;
    }

    if (serializer == null) {
      return jsonEncode(object);
    }

    if (object is JsonSerializableObject) {
      return object.toJson();
    }

    // 需要使用泛型
    if (_isGeneric(serializer, specifiedType)) {
      return _serializeWhitGeneric(object, serializer as StructuredSerializer, specifiedType ?? FullType.unspecified);
    }

    return jsonEncode(this._serializers.serializeWith(serializer, object));
  }

  bool _isEmpty(source) => source == null || (source is String && !StringUtils.hasText(source));

  bool _isGeneric(Serializer<dynamic> serializer, FullType specifiedType) {
    return serializer is StructuredSerializer && _isSpecifiedType(specifiedType);
  }

  _deserializeWithGeneric(Map json, Serializer<dynamic> serializer, FullType specifiedType) {
    final list = [];
    json.forEach((key, val) {
      list.add(key);
      list.add(val);
    });
    return (serializer as StructuredSerializer).deserialize(this._serializers, list, specifiedType: specifiedType);
  }

  _tryDecode(source) => source is String ? json.decode(source) : source;

  bool _isSpecifiedType(FullType specifiedType) =>
      specifiedType != null && specifiedType != FullType.unspecified && specifiedType != FullType.object;

  String _serializeWhitGeneric(object, StructuredSerializer<dynamic> serializer, FullType specifiedType) {
    // 泛型支持
    final result = serializer.serialize(this._serializers, object, specifiedType: specifiedType);
    final iterator = result.iterator;
    final map = {};
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      map[key] = value;
    }
    return jsonEncode(map);
  }
}

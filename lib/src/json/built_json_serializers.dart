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

  /// parse json text or [Map] or [List] or [Set] to object
  /// [source] type [String] or  [Map] or [List] or [Set]
  /// [serializer]  类型 serializer
  /// [formJson]    自定义的formJson 工厂方法
  /// [specifiedType]    FullType 存在泛型是需要
  /// 泛型支持需要 [SerializersBuilder.addBuilderFactory]
  T parseObject<T>(dynamic source, {Serializer<T> serializer, Function formJson, FullType specifiedType}) {
    if (source == null) {
      return null;
    }

    var isStringType = source is String;
    if (isStringType && !StringUtils.hasText(source)) {
      return null;
    }

    if (formJson != null) {
      // 自定义的fromJson方法
      return formJson(source);
    }

    final result = source; //isStringType ? json.decode(source) : source;
    if (serializer == null) {
      if (specifiedType != null && specifiedType != FullType.unspecified && specifiedType != FullType.object) {
        return this._serializers.deserialize(result, specifiedType: specifiedType);
      }
      return result;
    }

    // 需要使用泛型
    final isGeneric =
        serializer is StructuredSerializer && specifiedType != null && specifiedType != FullType.unspecified;

    if (isGeneric) {
      // 泛型支持
      final Map data = isStringType ? json.decode(source) : source;
      final list = [];
      data.forEach((key, val) {
        list.add(key);
        list.add(val);
      });
      return (serializer as StructuredSerializer).deserialize(this._serializers, list, specifiedType: specifiedType);
    }

    return this._serializers.deserializeWith(serializer, result);
  }

  /// object to string
  /// [object] serialize object
  /// [serializer] built serializer
  /// [specifiedType]
  String toJson<T>(object, {Serializer<T> serializer, FullType specifiedType}) {
    if (object == null) {
      return null;
    }

    if (serializer == null) {
      if (object is JsonSerializableObject) {
        return object.toJson();
      }
      return jsonEncode(object);
    }
    // 需要使用泛型
    final isGeneric =
        serializer is StructuredSerializer && specifiedType != null && specifiedType != FullType.unspecified;
    if (isGeneric) {
      // 泛型支持
      if (specifiedType == null) {
        specifiedType = FullType.unspecified;
      }
      var result =
          (serializer as StructuredSerializer).serialize(this._serializers, object, specifiedType: specifiedType);
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

    if (object is JsonSerializableObject) {
      return object.toJson();
    }
    return jsonEncode(this._serializers.serializeWith(serializer, object));
  }
}

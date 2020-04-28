import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:fengwuxp_dart_basic/index.dart';
import 'package:fengwuxp_dart_basic/src/utils/string_utils.dart';

class BuiltJsonSerializers {
  Serializers _serializers;

  BuiltJsonSerializers(this._serializers);

  factory(Serializers serializers) {
    return new BuiltJsonSerializers(serializers);
  }

  /// parse json text to object
  /// [jsonText]
  /// [serializer]  类型 serializer
  /// [formJson]    自定义的formJson 工厂方法
  /// [specifiedType]    FullType 存在泛型是需要
  /// 泛型支持需要 [SerializersBuilder.addBuilderFactory]
  T parseObject<T>(String jsonText,
      {Serializer<T> serializer, Function formJson, FullType specifiedType = FullType.unspecified}) {
    if (!StringUtils.hasText(jsonText)) {
      return null;
    }

    if (formJson != null) {
      return formJson(jsonText);
    }

    var result = jsonDecode(jsonText);
    if (serializer == null) {
      return result;
    }

    if (serializer is StructuredSerializer) {
      Map data = json.decode(jsonText);
      var list = [];
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
  String toJson<T>(object, {Serializer<T> serializer, FullType specifiedType = FullType.unspecified}) {
    if (object == null) {
      return null;
    }

    if (serializer == null) {
      if (object is JsonSerializableObject) {
        return object.toJson();
      }
      return jsonEncode(object);
    }
    if (serializer is StructuredSerializer) {
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

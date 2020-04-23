import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:fengwuxp_dart_basic/src/utils/string_utils.dart';

class BuiltJsonSerializers {
  Serializers _serializers;

  BuiltJsonSerializers(this._serializers);

  factory(Serializers serializers) {
    return new BuiltJsonSerializers(serializers);
  }

  T parseObject<T>(String jsonText, [Serializer<T> serializer]) {
    if (!StringUtils.hasText(jsonText)) {
      return null;
    }
    var result = jsonDecode(jsonText);
    if (serializer == null) {
      return result;
    }

    return this._serializers.deserializeWith(serializer, result);
  }

  String toJson<T>(object, [Serializer<T> serializer]) {
    if (object == null) {
      return null;
    }
    if (serializer == null) {
      return jsonEncode(object);
    }
    return jsonEncode(this._serializers.serializeWith(serializer, object));
  }
}

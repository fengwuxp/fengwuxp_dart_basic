import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/json/built_json_serializers.dart';
import 'hello/hello.dart';
import 'serializers.dart';

void main() {
  test('test json serizable', () {
    String jsonText = '''
 {
      "id": 157538,
      "date": "2017-07-21T10:30:34",
      "date_gmt": "2017-07-21T17:30:34",
      "type": "post",
      "link": "https://example.com",
      "title": {
          "rendered": "Json 2 dart built_value converter"
      },
      "tags": [
          1798,
          6298
      ]
    }
    ''';

    var hello = serializers.deserializeWith(Hello.serializer, jsonDecode(jsonText));

    print("==>${hello.id}");
    var _h = serializers.serializeWith(Hello.serializer, hello);
    print(json.encode(_h));

    var formJson = Hello.formJson(jsonText);
    print(formJson.toJson());

    var builtJsonSerializers = BuiltJsonSerializers(serializers);
    var parseObject = builtJsonSerializers.parseObject(jsonText, serializer: Hello.serializer);
     parseObject = builtJsonSerializers.parseObject(json.decode(jsonText), serializer: Hello.serializer);
    print("===> $parseObject");
    var toJson = builtJsonSerializers.toJson(parseObject, serializer: Hello.serializer);
    print("===> $toJson");
  });
}

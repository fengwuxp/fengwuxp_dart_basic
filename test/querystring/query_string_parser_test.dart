

import 'package:fengwuxp_dart_basic/index.dart';
import 'package:test/test.dart';

void main() {
  test("query string parse ", () {
    //http://www.baidu.com?
//    var queryString = Uri.encodeQueryComponent("a=1&b=2&c=3&b=4&h=我的&e=&f=你", encoding: utf8);
    var queryString = "a=1&b=2&c=3&b=4&h=我的&e=&f=你";
    var parse = QueryStringParser.parse(queryString);
    print("$parse");
    var string = QueryStringParser.stringify(parse);
    var queryParams = Uri.splitQueryString(string);
    print("splitQueryString ==>$queryParams");
    print("$string");
    parse = QueryStringParser.parse(string, needDecode: true);
    print("$parse");
  });
}

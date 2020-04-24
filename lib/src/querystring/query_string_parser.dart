// 查询字符串解析
class QueryStringParser {
  static final SEP = '&';
  static final EQ = '=';
  static final QUERY_TRING_SEP = '?';

  //  Parses the given query string into a Map.
  static Map<String, dynamic> parse(String query, {bool filterNoneValue = true}) {
    var search = new RegExp('([^&=]+)=?([^&]*)');
    var result = new Map<String, dynamic>();

    if (query == null || query.trim().length == 0) {
      return Map.from({});
    }

    // Get rid off the beginning ? in query strings.
    if (query.startsWith(QueryStringParser.QUERY_TRING_SEP)) query = query.substring(1);

    // A custom decoder.
    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      var value = decode(match.group(2));
      if (value.trim().length == 0 && filterNoneValue) {
        continue;
      }
      var key = decode(match.group(1));
      var item = result[key];
      if (item != null) {
        // if value exist ,converter to List
        if (!(item is List)) {
          item = [item];
        }
        item.add(value);
      } else {
        item = value;
      }
      result[key] = item;
    }

    return result;
  }

  static String stringify(Map queryParams, {bool filterNoneValue = true}) {
    StringBuffer queryString = StringBuffer();
    queryParams.forEach((key, val) {
      _writeStringify(queryString, key, val, filterNoneValue);
    });

    return queryString.toString().substring(1, queryString.length);
  }

  static void _writeStringify(StringBuffer queryString, String key, val, bool filterNoneValue) {
    if (val == null && filterNoneValue) {
      return;
    }
    if (val is String) {
      if (val.trim().length == 0) {
        return;
      }
    }
    if (val is List) {
      val.forEach((item) {
        _writeStringify(queryString, key, item, filterNoneValue);
      });
    } else {
      queryString.write(QueryStringParser.SEP);
      queryString.write("$key${QueryStringParser.EQ}${val}");
    }
  }
}

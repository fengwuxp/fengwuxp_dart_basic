RegExp replaceSymbolRegExp = new RegExp('Symbol|\\("|"\\)');


/// 解析 Symbol的name
String? parseSymbolName(Symbol? symbol) {
  if (symbol == null) {
    return null;
  }
  return symbol.toString().replaceAll(replaceSymbolRegExp, "");
}

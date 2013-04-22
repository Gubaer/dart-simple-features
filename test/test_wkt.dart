library test_wkt;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart";

part "../lib/src/util.dart";
part "../lib/src/geometry.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multilinestring.dart";
part "../lib/src/wkt.dart";

main() {
  group("elementary token type test - ", () {
    test("empty input", () {
      var tokenizer = new _WKTTokenizer("".codeUnits);
      expect(tokenizer.next().type, _WKTTokenType.EOS);
    });

    test("whitespace input", () {
      var tokenizer = new _WKTTokenizer("  ".codeUnits, skipWhitespace:false);
      expect(tokenizer.next().type, _WKTTokenType.WHITESPACE);
    });

    test("keyword input", () {
      var tokenizer = new _WKTTokenizer("abc".codeUnits);
      expect(tokenizer.next().type, _WKTTokenType.KEYWORD);
    });


    test("comma input", () {
      var tokenizer = new _WKTTokenizer(",".codeUnits);
      expect(tokenizer.next().type, _WKTTokenType.COMMA);
    });

    test("quoted name input", () {
      var tokenizer = new _WKTTokenizer("\"abc 123 _.()\"".codeUnits);
      expect(tokenizer.next().type, _WKTTokenType.QUOTED_NAME);
    });
  });

  group("numeric literals - ", () {
    generic_test(data) {
      var tokenizer = new _WKTTokenizer(data.codeUnits);
      var token = tokenizer.next();
      expect(token.type, _WKTTokenType.NUMERIC_LITERAL);
      expect(token.value, data);
      double.parse(token.value);
    }

    test("unsigned integer", () {
      generic_test("123");
    });

    test("signed integer - '+'", () {
      generic_test("+123");
    });

    test("signed integer - '-'", () {
      generic_test("-123");
    });

    test("unsigned decimal", () {
      generic_test("123.456");
    });

    test("unsigned decimal - starts with '.'", () {
      generic_test(".456");
    });

    test("signed decimal - '+'", () {
      generic_test("+123.456");
    });
    test("signed decimal - '-'", () {
      generic_test("-123.456");
    });

    test("signed decimal starting with '.' - '+'", () {
      generic_test("+.456");
    });

    test("signed decimal starting with '.' - '-'", () {
      generic_test("-.456");
    });

    test("approximate literal - 123E123", () {
      generic_test("123E123");
    });

    test("approximate literal - 123E+123", () {
      generic_test("123E+123");
    });
    test("approximate literal - 123E-123", () {
      generic_test("123E-123");
    });
    test("approximate literal - 123.123E123", () {
      generic_test("123.123E-123");
    });
    test("approximate literal - 123.123E+123", () {
      generic_test("123.123E-123");
    });
    test("approximate literal - 123.123E-123", () {
      generic_test("123.123E-123");
    });
    test("approximate literal - +123.123E123", () {
      generic_test("+123.123E123");
    });
    test("approximate literal - -123.123E123", () {
      generic_test("-123.123E123");
    });
  });

  group("tokenize wkt fragments - ", () {
    test("point xy", () {
      var data = "point (123 456)";
      var tokenizer = new _WKTTokenizer(data.codeUnits);
      var token = tokenizer.next();
      expect(token.type, _WKTTokenType.KEYWORD);
      expect(token.value, "point");
      token = tokenizer.next();
      expect(token.type, _WKTTokenType.LPAREN);
      expect(token.value, "(");
      token = tokenizer.next();
      expect(token.type, _WKTTokenType.NUMERIC_LITERAL);
      expect(token.value, "123");
      token = tokenizer.next();
      expect(token.type, _WKTTokenType.NUMERIC_LITERAL);
      expect(token.value, "456");
      token = tokenizer.next();
      expect(token.type, _WKTTokenType.RPAREN);
      expect(token.value, ")");

    });
  });

  group("parse points - ", () {
    test("point xy", () {
      var wkt = "point (123 456)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var point = parser.parsePoint();
      expect(point.x, 123);
      expect(point.y, 456);
      expect(point.z, null);
      expect(point.m, null);
    });

    test("point z", () {
      var wkt = "point z (123 456 789)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var point = parser.parsePoint();
      expect(point.x, 123);
      expect(point.y, 456);
      expect(point.z, 789);
      expect(point.m, null);
    });

    test("point m", () {
      var wkt = "point m (123 456 789)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var point = parser.parsePoint();
      expect(point.x, 123);
      expect(point.y, 456);
      expect(point.z, null);
      expect(point.m, 789);
    });

    test("point zm", () {
      var wkt = "point zm (123 456 789 -123.456)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var point = parser.parsePoint();
      expect(point.x, 123);
      expect(point.y, 456);
      expect(point.z, 789);
      expect(point.m, -123.456);
    });

  });

  /* --------------------------------------------------------------------- */
  group("parse multipoint - ", () {
    test("empty", () {
      var wkt = "multipoint empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.isEmpty, true);
    });

    test("single xy", () {
      var wkt = "multipoint ((1 2))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.length, 1);
      expect(mp.first.x, 1);
      expect(mp.first.y, 2);
    });

    test("single xyz", () {
      var wkt = "multipoint z ((1 2 3))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.length, 1);
      expect(mp.first.x, 1);
      expect(mp.first.y, 2);
      expect(mp.first.z, 3);
    });

    test("single xym", () {
      var wkt = "multipoint m ((1 2 3))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.length, 1);
      expect(mp.first.x, 1);
      expect(mp.first.y, 2);
      expect(mp.first.m, 3);
    });

    test("single xyzm", () {
      var wkt = "multipoint zm ((1 2 3 4))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.length, 1);
      expect(mp.first.x, 1);
      expect(mp.first.y, 2);
      expect(mp.first.z, 3);
      expect(mp.first.m, 4);
    });

    test("multiple xy", () {
      var wkt = "multipoint ((11 12), (21 22), (31 32))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mp = parser.parseMultiPoint();
      expect(mp.length, 3);
      expect([mp[0].x, mp[0].y], [11, 12]);
      expect([mp[1].x, mp[1].y], [21, 22]);
      expect([mp[2].x, mp[2].y], [31, 32]);
    });
  });

  /* --------------------------------------------------------------------- */
  group("parse linestring - ", () {
    test("empty", () {
      var wkt = "linestring empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var ls = parser.parseLineString();
      expect(ls.isEmpty, true);
    });

    test("a line with two points", () {
      var wkt = "linestring (1 2, 3 4)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var ls = parser.parseLineString();
      expect(ls.length, 2);
      expect(ls.first.x, 1);
      expect(ls.last.y, 4);
    });

    test("a linestring with two 3d points", () {
      var wkt = "linestring z (1 2 3, 4.0 +5 -6E1)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var ls = parser.parseLineString();
      expect(ls.length, 2);
      expect(ls.is3D, true);
      expect(ls.last.z, -60);
    });

    test("a linestring with two measured points", () {
      var wkt = "LINeStrIng M (1 2 3, 4.0 +5 -6E1)";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var ls = parser.parseLineString();
      expect(ls.length, 2);
      expect(ls.isMeasured, true);
      expect(ls.last.m, -60);
    });
  });

  /* --------------------------------------------------------------------- */
  group("parse multilinestring - ", () {
    test("empty", () {
      var wkt = "multilinestring empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mls = parser.parseMultiLineString();
      expect(mls.isEmpty, true);
    });

    test("a multilinestring with one line string", () {
      var wkt = "multilinestring ( (1 2, 3 4, 5 6) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mls = parser.parseMultiLineString();
      expect(mls.length, 1);
      expect(mls.first is LineString, true);
    });

    test("a multilinestring with two 3D linestrings", () {
      var wkt = "multilinestring z ( (1 2 3, 4.0 +5 -6E1, 4 5 6), (1 2 3, 4 5 6, 7 8 9))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mls = parser.parseMultiLineString();
      expect(mls.length, 2);
      expect(mls.is3D, true);
    });
  });



  /* --------------------------------------------------------------------- */
  group("parse WKT - ", () {
    test("with a point", () {
      var wkt = "point (1 2)";
      var g = parseWKT(wkt);
      expect(g is Point, true);
    });
    test("with a multipoint", () {
      var wkt = "multipoint ( (1 2), (3 4))";
      var g = parseWKT(wkt);
      expect(g is MultiPoint, true);
    });
    test("with a linestring", () {
      var wkt = "linestring (1 2, 3 4, 5 6)";
      var g = parseWKT(wkt);
      expect(g is LineString, true);
    });

    test("with a multilinestring", () {
      var wkt = "multilinestring ( (1 2, 3 4, 5 6), (1 2, 3 4, 5 6))";
      var g = parseWKT(wkt);
      expect(g is MultiLineString, true);
    });


  });
}


library test_wkt;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;

part "../lib/src/util.dart";
part "../lib/src/geometry.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multilinestring.dart";
part "../lib/src/wkt.dart";
part "../lib/src/surface.dart";
part "../lib/src/polygon.dart";
part "../lib/src/multipolygon.dart";
part "../lib/src/polyhedral_surface.dart";

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
      var wkt = "multilinestring z ( (1 2 3, 4.0 +5 -6E1, 4 7 6), (1 2 3, 4 5 6, 7 8 9))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var mls = parser.parseMultiLineString();
      expect(mls.length, 2);
      expect(mls.is3D, true);
    });
  });

  /* --------------------------------------------------------------------- */
  group("parse polygon - ", () {
    test("empty", () {
      var wkt = "polygon empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var p = parser.parsePolygon();
      expect(p.isEmpty, true);
    });

    test("a polygon with an exterior ring only", () {
      var wkt = "polygon ( (1 2, 3 4, 5 6, 1 2) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var p = parser.parsePolygon();
      expect(p.isEmpty, false);
      expect(p.interiorRings.isEmpty, true);
      expect(p.exteriorRing, isNotNull);
    });

    test("a polygon with an exterior and two interior rings", () {
      var wkt = "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
                         " (1 1, 1 2, 2 2, 2 1, 1 1), "
                         " (50 50, 50 60, 60 60, 60 50, 50 50) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var p = parser.parsePolygon();
      expect(p.isEmpty, false);
      expect(p.interiorRings.length, 2);
      expect(p.exteriorRing, isNotNull);
    });

    test("a 3D polygon", () {
      var wkt = "polygon z ( (0 0 0, 0 100 0, 100 100 0, 100 0 0, 0 0 0), "
                         " (1 1 0, 1 2 0, 2 2 0, 2 1 0, 1 1 0), "
                         " (50 50 0, 50 60 0, 60 60 0, 60 50 0, 50 50 0) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var p = parser.parsePolygon();
      expect(p.isEmpty, false);
      expect(p.interiorRings.length, 2);
      expect(p.exteriorRing, isNotNull);
      expect(p.is3D, true);
    });

    test("a measured 3D polygon", () {
      var wkt = "polygon zm ( (0 0 0 0, 0 100 0 0, 100 100 0 0, 100 0 0 0, 0 0 0 0), "
                         " (1 1 0 0, 1 2 0 0, 2 2 0 0, 2 1 0 0, 1 1 0 0), "
                         " (50 50 0 0, 50 60 0 0, 60 60 0 0, 60 50 0 0, 50 50 0 0) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var p = parser.parsePolygon();
      expect(p.isEmpty, false);
      expect(p.interiorRings.length, 2);
      expect(p.exteriorRing, isNotNull);
      expect(p.is3D, true);
    });
  });

  /* --------------------------------------------------------------------- */
  group("parse multipolygon - ", () {
    test("empty", () {
      var wkt = "multipolygon empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseMultiPolygon();
      expect(g.isEmpty, true);
    });

    test("a multipolygon with one polygon", () {
      var wkt = "multipolygon ( ((1 2, 3 4, 5 6, 1 2)))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseMultiPolygon();
      expect(g.isEmpty, false);
      expect(g.length, 1);
    });

    test("a multipolygon with one polygon with internal rings", () {
      var wkt = "multipolygon ( ( (0 0, 0 100, 100 100, 100 0, 0 0), "
                         " (1 1, 1 2, 2 2, 2 1, 1 1), "
                         " (50 50, 50 60, 60 60, 60 50, 50 50) ) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseMultiPolygon();
      expect(g.length, 1);
    });

    test("a 3D multipolygon with two polygons", () {
      var wkt = "multipolygon z ("
                         // polygon 1
                         "( (1 2 0, 3 4 0, 5 6 0, 1 2 0) ),"
                         // polygon 2
                         "( (0 0 0, 0 100 0, 100 100 0, 100 0 0, 0 0 0), "
                         "  (1 1 0, 1 2 0, 2 2 0, 2 1 0, 1 1 0), "
                         "  (50 50 0, 50 60 0, 60 60 0, 60 50 0, 50 50 0) )"
                         ")";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseMultiPolygon();
      expect(g.length, 2);
    });
  });


  /* --------------------------------------------------------------------- */
  group("parse polyhedralsurface - ", () {
    test("empty", () {
      var wkt = "polyhedralsurface empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parsePolyhedralSurface();
      expect(g.isEmpty, true);
    });

    test("a polyhedralsurface with one polygon", () {
      var wkt = "polyhedralsurface ( ((1 2, 3 4, 5 6, 1 2)))";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parsePolyhedralSurface();
      expect(g.isEmpty, false);
      expect(g.length, 1);
    });

    test("a polyhedralsurface with one polygon with internal rings", () {
      var wkt = "polyhedralsurface ( ( (0 0, 0 100, 100 100, 100 0, 0 0), "
                         " (1 1, 1 2, 2 2, 2 1, 1 1), "
                         " (50 50, 50 60, 60 60, 60 50, 50 50) ) )";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parsePolyhedralSurface();
      expect(g.length, 1);
    });

    test("a 3D polyhedralsurface with two polygons", () {
      var wkt = "polyhedralsurface z ("
                         // polygon 1
                         "( (1 2 0, 3 4 0, 5 6 0, 1 2 0) ),"
                         // polygon 2
                         "( (0 0 0, 0 100 0, 100 100 0, 100 0 0, 0 0 0), "
                         "  (1 1 0, 1 2 0, 2 2 0, 2 1 0, 1 1 0), "
                         "  (50 50 0, 50 60 0, 60 60 0, 60 50 0, 50 50 0) )"
                         ")";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parsePolyhedralSurface();
      expect(g.length, 2);
    });
  });

  /* --------------------------------------------------------------------- */
  group("parse geometrycollection -", () {
    test("empty", () {
      var wkt = "geometrycollection empty";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseGeometryCollection();
      expect(g.isEmpty, true);
    });

    test("geometry collection with a point", () {
      var wkt = "geometrycollection ("
                "  point (1 2)"
                ")";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseGeometryCollection();
      expect(g.isEmpty, false);
      expect(g.length, 1);
    });

    test("geometry collection with a point and a 3D linestring", () {
      var wkt = "geometrycollection ("
                "  point (1 2),"
                "  linestring z (1 2 0, 2 3 0, 4 5 0, 6 7 0)"
                ")";
      var parser = new _WKTParser(wkt);
      parser.advanceMandatory();
      var g = parser.parseGeometryCollection();
      expect(g.isEmpty, false);
      expect(g.length, 2);
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

    test("with a polygon", () {
      var wkt = "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
          " (1 1, 1 2, 2 2, 2 1, 1 1), "
          " (50 50, 50 60, 60 60, 60 50, 50 50) )";
      var g = parseWKT(wkt);
      expect(g is Polygon, true);
    });

    test("with a multipolygon", () {
      var wkt = "multipolygon ( ( (0 0, 0 100, 100 100, 100 0, 0 0), "
          " (1 1, 1 2, 2 2, 2 1, 1 1), "
          " (50 50, 50 60, 60 60, 60 50, 50 50) ) )";
      var g = parseWKT(wkt);
      expect(g is MultiPolygon, true);
    });

    test("with a geometrycollection", () {
      var wkt = "geometrycollection ("
          "  point (1 2),"
          "  linestring z (1 2 0, 2 3 0, 4 5 0, 6 7 0)"
          ")";
      var g = parseWKT(wkt);
      expect(g is GeometryCollection, true);
    });
  });
}



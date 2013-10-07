library test_multilinestring;

import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
import "package:meta/meta.dart";
import "dart:convert";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multilinestring.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/wkt.dart";
part "../lib/src/direct_position.dart";
part "../lib/src/geojson.dart";
main() {
  group("constructor -", () {
    test("empty() constructor", () {
      var mls= new MultiLineString.empty();
      expect(mls.isEmpty, true);
    });
    test("null list leads to empty multilinestring", () {
      var mls = new MultiLineString(null);
      expect(mls.isEmpty, true);
    });
    test("empty list of linestrings leads to empty multilinestring", () {
      var mls = new MultiLineString([]);
      expect(mls.isEmpty, true);
    });

    test("create a multilinestring with three children", () {
      var children = [
         parseWKT("linestring empty"),
         parseWKT("linestring (1 2, 3 4, 5 6, 7 8)"),
         parseWKT("linestring z (10 11 12, 20 21 22)"),
      ];
      var mls = new MultiLineString(children);
      expect(mls.isEmpty, false);
      expect(mls.length, 3);
    });
    test("don't allow nulls in child list", () {
      var children = [
         parseWKT("linestring empty"),
         parseWKT("linestring (1 2, 3 4, 5 6, 7 8)"),
         parseWKT("linestring z (10 11 12, 20 21 22)"),
         null
      ];
      var mls;
      expect(() => mls = new MultiLineString(children),
          throwsA(new isInstanceOf<ArgumentError>())
      );
    });
  });

  /* ---------------------------------------------------------------- */
  group("boundary -", () {
    test("of an empty multilinestring is empty", () {
      var mls= new MultiLineString.empty();
      expect(mls.boundary.isEmpty, true);
    });
    test("one non closed child -> the boundary consists of the endpoints", () {
      var children = [
         parseWKT("linestring (1 2, 3 4, 5 6, 7 8)")
      ];
      var mls = new MultiLineString(children);
      expect(mls.boundary.length, 2);
      expect(mls.boundary.where((p) => p.x == 1).length, 1);
      expect(mls.boundary.where((p) => p.x == 7).length, 1);
    });
    test("one closed child -> the boundary is empty", () {
      var children = [
         parseWKT("linestring (1 2, 3 4, 5 6, 7 8, 1 2)")
      ];
      var mls = new MultiLineString(children);
      expect(mls.boundary.isEmpty, true);
    });

    test("two open children, one shared endpoint -> 2 of 4 endpoints in the boundary", () {
      var children = [
         parseWKT("linestring (1 2, 3 4, 5 6)"),
         parseWKT("linestring (5 6, 7 8, 9 10)")
      ];
      var mls = new MultiLineString(children);
      expect(mls.boundary.length, 2);
      expect(mls.boundary.where((p) => p.x == 1).length, 1);
      expect(mls.boundary.where((p) => p.x == 9).length, 1);
    });

  });

  group("asText -", () {
    test("of an empty multilinestring", () {
      var mls = new MultiLineString.empty();
      mls = parseWKT(mls.asText);
      expect(mls is MultiLineString, true);
      expect(mls.isEmpty, true);
    });

    test("multi line string with three line strings", () {
      var children = [
         parseWKT("linestring empty"),
         parseWKT("linestring (1 2, 3 4, 5 6, 7 8)"),
         parseWKT("linestring (10 11, 20 21)")
      ];
      var mls = new MultiLineString(children);
      mls = parseWKT(mls.asText);
      expect(mls is MultiLineString, true);
      expect(mls.length, 3);
      expect(mls.first.isEmpty, true);
    });
  });

  /* --------------------------------------------------------------------- */
  group("geojson -", () {
    test("- deserialize a multilinestring", () {
      var gjson = """
      {"type": "MultiLineString", "coordinates": [
        [[1,2], [3,4], [5,6]],
        [[11,12], [13,14], [15,16]],
        [[21,22], [22,24], [25,26]]
      ]}
      """;
      var o = parseGeoJson(gjson);
      expect(o is MultiLineString, true);
      expect(o.length, 3);
      for (int i=0; i<o.length; i++) {
        expect(o[i] is LineString, true);
      }
      expectPoints(ls, points) {
        for (int i=0; i< points.length; i++) {
          expect(ls[i].x, points[i][0]);
          expect(ls[i].y, points[i][1]);
        }
      }
      expectPoints(o[0], [[1,2], [3,4], [5,6]]);
      expectPoints(o[1], [[11,12], [13,14], [15,16]]);
      expectPoints(o[2], [[21,22], [22,24], [25,26]]);
    });
  });
}

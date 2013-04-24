library test_multilinestring;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart";
import "package:meta/meta.dart";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multilinestring.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/wkt.dart";
part "../lib/src/direct_position.dart";

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

}
library test_polygon;

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
part "../lib/src/surface.dart";
part "../lib/src/polygon.dart";
part "../lib/src/geojson.dart";

main() {
  group("constructor -", () {
    test("empty() constructor", () {
      var p= new Polygon.empty();
      expect(p.isEmpty, true);
    });
    test("empty exterior ring leads to empty polygon", () {
      var p = new Polygon(new LineString.empty(), null);
      expect(p.isEmpty, true);
    });
    test("exterior ring must not be null", () {
      var p;
      expect(() => p = new Polygon(null, []),
          throwsA(new isInstanceOf<ArgumentError>()));
    });
    test("exterior ring must not be null", () {
      var p;
      expect(() => p = new Polygon(null, []),
          throwsA(new isInstanceOf<ArgumentError>()));
    });
    test("interior rings must be null or empty, if exterior is empty", () {
      var p;
      p = new Polygon(new LineString.empty(), null); // OK
      p = new Polygon(new LineString.empty(), []); // OK

      var interiors = [
        parseWKT("linestring (1 1, 2 2, 3 3, 4 4)")
      ];

      expect(
          () => p = new Polygon(new LineString.empty(), interiors),
          throwsA(new isInstanceOf<ArgumentError>())
      );


    });

    test("interior rings must not be null", () {
      var p;
      p = new Polygon(new LineString.empty(), null); // OK
      p = new Polygon(new LineString.empty(), []); // OK

      var interiors = [
        parseWKT("linestring (1 1, 2 2, 3 3, 4 4, 1 1)"),
        null
      ];

      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");

      expect(
          () => p = new Polygon(exterior, interiors),
          throwsA(new isInstanceOf<ArgumentError>())
      );
    });
  });

  /* ---------------------------------------------------------------- */
  group("dimension -", () {
    test("is 2 for non-empty polygons", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var p = new Polygon(exterior, null);
      expect(p.dimension, 2);
    });

    test("is 2 for empty polygons", () {
      var p = new Polygon(new LineString.empty(), null);
      expect(p.dimension, 2);
    });
  });

  /* ---------------------------------------------------------------- */
  group("geometryType -", () {
    test("is 'Polygon'", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var p = new Polygon(exterior, null);
      expect(p.geometryType, "Polygon");
    });
  });

  /* ---------------------------------------------------------------- */
  group("exteriorRing -", () {
    test("is an empty line string for an empty polygon", () {
      var p = new Polygon.empty();
      expect(p.exteriorRing is LineString, true);
      expect(p.exteriorRing.isEmpty, true);
    });

    test("is a non empty line string for a non-empty polygon", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var p = new Polygon(exterior, null);
      expect(p.exteriorRing is LineString, true);
      expect(p.exteriorRing.isEmpty, false);
    });
  });

  /* ---------------------------------------------------------------- */
  group("interiorRings -", () {
    test("is an empty iterable for an empty polygon", () {
      var p = new Polygon.empty();
      expect(p.interiorRings.isEmpty, true);
    });

    test("is a empty iterable for an polygon without holes", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var p = new Polygon(exterior, null);
      expect(p.interiorRings.isEmpty, true);
    });

    test("is an iterable of the internal rings for a polygon with holes", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var interiors = [
        parseWKT("linestring (1 1, 2 2, 3 3, 4 4, 1 1)"),
        parseWKT("linestring (10 11, 20 21, 30 31, 40 41, 10 11)")
      ];

      var p = new Polygon(exterior, interiors);
      expect(p.interiorRings.length, 2);
      expect(p.interiorRings.every((r) => r is LineString), true);
    });
  });

  /* ---------------------------------------------------------------- */
  group("triangle -", () {
    test("must consist of a closed linestring with three coordinates ", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 0 100, 0 0)");
      var p = new Polygon.triangle(exterior);
    });
  });

  group("triangle -", () {
    test("a triangle with too many nodes ", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 0 100, 50 50, 0 0)");
      var p;
      expect(() => new Polygon.triangle(exterior),
          throwsA(new isInstanceOf<ArgumentError>()));
    });

    test("a non-closed triangle isn't a triangle", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 0 100, 50 50)");
      var p;
      expect(() => new Polygon.triangle(exterior),
          throwsA(new isInstanceOf<ArgumentError>()));
    });

    test("the exterior must not be null", () {
      var p;
      expect(() => p = new Polygon.triangle(null),
          throwsA(new isInstanceOf<ArgumentError>()));
    });
  });

  /* ---------------------------------------------------------------- */
  group("asText -", () {
    test("of an empty polygon", () {
      var p = new Polygon.empty();
      print(p.asText);

      p = parseWKT(p.asText);

      expect(p is Polygon, true);
      expect(p.isEmpty, true);
    });

    test("of a polygon without holes", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var p = new Polygon(exterior, null);
      p = parseWKT(p.asText);
      expect(p is Polygon, true);
      expect(p.isEmpty, false);
    });

    test("of a polygon with holes", () {
      var exterior = parseWKT("linestring (0 0, 100 0, 100 100, 0 100, 0 0)");
      var interiors = [
        parseWKT("linestring (1 1, 2 2, 3 3, 4 4, 1 1)"),
        parseWKT("linestring (10 11, 20 21, 30 31, 40 41, 10 11)")
      ];

      var p = new Polygon(exterior, interiors);
      p = parseWKT(p.asText);
      expect(p is Polygon, true);
      expect(p.isEmpty, false);
      expect(p.interiorRings.length, 2);
    });
  });

  /* -------------------------------------------------------------------- */
  group("geojson -", () {
    expectPoints(ls, points) {
      for (int i=0; i< points.length; i++) {
        expect(ls[i].x, points[i][0]);
        expect(ls[i].y, points[i][1]);
      }
    }

    test("- Polygon", () {
      var gjson = """
      {"type": "Polygon", "coordinates": [
        [[1,2], [3,4], [5,6], [1,2]],
        [[11,12], [13,14], [15,16], [11,12]],
        [[21,22], [22,24], [25,26], [21,22]]
      ]}
      """;
      var o = parseGeoJson(gjson);
      expect(o is Polygon, true);
      o = (o as Polygon);
      expect(o.exteriorRing, isNotNull);
      expect(o.interiorRings.length, 2);
      expectPoints(o.exteriorRing, [[1,2], [3,4], [5,6]]);
      expectPoints(o.interiorRings[0], [[11,12], [13,14], [15,16]]);
      expectPoints(o.interiorRings[1], [[21,22], [22,24], [25,26]]);
    });

  });
}

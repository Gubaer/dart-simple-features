library test_multipolygon;

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
part "../lib/src/multipolygon.dart";
part "../lib/src/polygon.dart";
part "../lib/src/surface.dart";
part "../lib/src/geojson.dart";

const POLYGON_1 =  "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
" (1 1, 1 2, 2 2, 2 1, 1 1), "
" (50 50, 50 60, 60 60, 60 50, 50 50) )";

main() {
  group("constructor -", () {
    test("empty() constructor", () {
      var mp = new MultiPolygon.empty();
      expect(mp.isEmpty, true);
    });

    test("null list of polygons is allowed", () {
      var mp = new MultiPolygon(null);
      expect(mp.isEmpty, true);
    });

    test("empty list of polygons is allowed", () {
      var mp = new MultiPolygon([]);
      expect(mp.isEmpty, true);
    });

    test("crate a multipolygon with one polygon", () {
      var wkt = "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
          " (1 1, 1 2, 2 2, 2 1, 1 1), "
          " (50 50, 50 60, 60 60, 60 50, 50 50) )";

      var polygon = parseWKT(wkt);
      var mp = new MultiPolygon([polygon]);
      expect(mp.isEmpty, false);
      expect(mp.length, 1);
    });
  });

  /* --------------------------------------------------------------- */
  group("dimension -", () {
    test("is always 2", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(mp.dimension, 2);
    });
  });

  /* --------------------------------------------------------------- */
  group("geometryType -", () {
    test("is always 'MultiPolygon'", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(mp.geometryType, "MultiPolygon");
    });
  });

  /* --------------------------------------------------------------- */
  group("boundary -", () {
    test("should be empty for an empty polygon", () {
      var mp = new MultiPolygon.empty();
      expect(mp.boundary.isEmpty, true);
    });
    test("single child => should consist of the boundary of the single child", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(mp.boundary.isEmpty, false);
      expect(mp.boundary.length, 3);
    });
  });

  /* --------------------------------------------------------------- */
  group("area -", () {
    test("not yet implemented", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(() => mp.area, throwsA(new isInstanceOf<UnimplementedError>()));
    });
  });

  /* --------------------------------------------------------------- */
  group("centroid -", () {
    test("not yet implemented", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(() => mp.centroid, throwsA(new isInstanceOf<UnimplementedError>()));
    });
  });

  /* --------------------------------------------------------------- */
  group("pointOnSurface -", () {
    test("not yet implemented", () {
      var polygon = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([polygon]);
      expect(() => mp.pointOnSurface, throwsA(new isInstanceOf<UnimplementedError>()));
    });
  });

  /* --------------------------------------------------------------- */
  group("asText -", () {
    test("of an empty multipolygon", () {
      var mp = new MultiPolygon.empty();
      mp = parseWKT(mp.asText);
      expect(mp.runtimeType, MultiPolygon);
      expect(mp.isEmpty,true);
    });

    test("with a single polygon", () {
      var p = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([p]);
      mp = parseWKT(mp.asText);
      expect(mp.runtimeType, MultiPolygon);
      expect(mp.length,1);
    });

    test("with three polygons", () {
      var p = parseWKT(POLYGON_1);
      var mp = new MultiPolygon([p,p,p]);
      mp = parseWKT(mp.asText);
      expect(mp.runtimeType, MultiPolygon);
      expect(mp.length,3);
    });
  });

  /* ----------------------------------------------------------------- */
  group("geojson -", () {
    test("- deserialize a multipolygon", () {
      var gjson = """
      {"type": "MultiPolygon", "coordinates": [
        [
          [[1,2], [3,4], [5,6], [1,2]],
          [[11,12], [13,14], [15,16], [11,12]],
          [[21,22], [22,24], [25,26], [21,22]]
        ],
        [
          [[101,102], [103,104], [105,106], [101,102]],
          [[111,112], [113,114], [115,116], [111,112]],
          [[121,122], [123,124], [125,126], [121,122]]
        ],
        [
          [[201,202], [203,204], [205,206], [201,202]],
          [[211,212], [213,214], [215,216], [211,212]],
          [[221,222], [223,224], [225,226], [221,222]]
        ]
      ]}
      """;
      var o = parseGeoJson(gjson);
      expect(o is MultiPolygon, true);
      o = (o as MultiPolygon);
      expect(o.length, 3);
      expect(o[0] is Polygon, true);
      expect(o[1] is Polygon, true);
      expect(o[2] is Polygon, true);
    });
  });
}
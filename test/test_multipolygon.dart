library test_multipolygon;

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
part "../lib/src/multipolygon.dart";
part "../lib/src/polygon.dart";
part "../lib/src/surface.dart";

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


}
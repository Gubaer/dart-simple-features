library test_polyhedral_surface;

import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
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
part "../lib/src/polyhedral_surface.dart";

const POLYGON_1 =  "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
" (1 1, 1 2, 2 2, 2 1, 1 1), "
" (50 50, 50 60, 60 60, 60 50, 50 50) )";

main() {
  group("constructor -", () {
    test("empty() constructor", () {
      var mp = new PolyhedralSurface.empty();
      expect(mp.isEmpty, true);
    });

    test("null list of polygons is allowed", () {
      var mp = new PolyhedralSurface(null);
      expect(mp.isEmpty, true);
    });

    test("empty list of polygons is allowed", () {
      var mp = new PolyhedralSurface([]);
      expect(mp.isEmpty, true);
    });

    test("create a polyhedral surface with one polygon", () {
      var wkt = "polygon ( (0 0, 0 100, 100 100, 100 0, 0 0), "
          " (1 1, 1 2, 2 2, 2 1, 1 1), "
          " (50 50, 50 60, 60 60, 60 50, 50 50) )";

      var polygon = parseWKT(wkt);
      var mp = new PolyhedralSurface([polygon]);
      expect(mp.isEmpty, false);
      expect(mp.length, 1);
    });
  });

  /* --------------------------------------------------------------- */
  group("dimension -", () {
    test("is always 2", () {
      var polygon = parseWKT(POLYGON_1);
      var g = new PolyhedralSurface([polygon]);
      expect(g.dimension, 2);
    });
  });

  /* --------------------------------------------------------------- */
  group("geometryType -", () {
    test("is always 'PolyhedralSurface'", () {
      var polygon = parseWKT(POLYGON_1);
      var g = new PolyhedralSurface([polygon]);
      expect(g.geometryType, "PolyhedralSurface");
    });
  });

  /* --------------------------------------------------------------- */
  group("boundary -", () {
    //TODO:
  });

  /* --------------------------------------------------------------- */
  group("asText -", () {
    test("of an empty polyhedralsurface", () {
      var g = new PolyhedralSurface.empty();
      g = parseWKT(g.asText);
      expect(g.runtimeType, PolyhedralSurface);
      expect(g.isEmpty,true);
    });

    test("with a single polygon", () {
      var p = parseWKT(POLYGON_1);
      var g = new PolyhedralSurface([p]);
      g = parseWKT(g.asText);
      expect(g.runtimeType, PolyhedralSurface);
      expect(g.length,1);
    });

    test("with three polygons", () {
      var p = parseWKT(POLYGON_1);
      var g = new PolyhedralSurface([p,p,p]);
      g = parseWKT(g.asText);
      expect(g.runtimeType, PolyhedralSurface);
      expect(g.length,3);
    });
  });

}
library test_point;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
import "package:meta/meta.dart";
import "dart:json" as json;

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/wkt.dart";
part "../lib/src/geojson.dart";
part "../lib/src/direct_position.dart";


main() {

  group("constructor -", () {
    test("empty point", () {
      var p = new Point.empty();
      expect(p.isEmpty,true);
    });

    test("with x,y coordinates", () {
      var p = new Point(1,2);
      expect(p.x, 1);
      expect(p.y, 2);
    });

    test("with z coordinates", () {
      var p = new Point(1,2, z:3);
      expect(p.x, 1);
      expect(p.y, 2);
      expect(p.z, 3);
      expect(p.m, null);
    });

    test("with m coordinates", () {
      var p = new Point(1,2, m:3);
      expect(p.x, 1);
      expect(p.y, 2);
      expect(p.m, 3);
    });

    test("from wkt - empty", () {
      var p = new Point.wkt("point empty");
      expect(p.isEmpty, true);
    });

    test("from wkt - measured 3D point", () {
      var p = new Point.wkt("point mz (1 2 3 4)");
      expect(p.isEmpty, false);
      expect(p.x,1);
      expect(p.y,2);
      expect(p.z,3);
      expect(p.m,4);
    });
  });

  group("boundary -", () {
    test("the boundary of an empty point is empty", () {
      var p = new Point.empty();
      expect(p.boundary.isEmpty, true);
    });

    test("the boundary of any point is empty", () {
      var p = new Point(1,2);
      expect(p.boundary.isEmpty, true);
    });
  });


  group("asText -", () {
    test("of an empty point", () {
      var p = new Point.empty();
      expect(p.asText, "POINT EMPTY");
    });

    test("a 2D point with two int coordinates", () {
      var p = new Point(1,2);
      expect(p.asText, "POINT (1 2)");
      expect(parseWKT(p.asText) is Point, true);
    });

    test("a 3D point with two int and a double coordinate", () {
      var p = new Point(1,2, z: 3.1);
      expect(p.asText, "POINT Z (1 2 3.1)");
      expect(parseWKT(p.asText) is Point, true);
    });

    test("a measured point with two int and a double coordinate", () {
      var p = new Point(1,2, m: 3.1);
      expect(p.asText, "POINT M (1 2 3.1)");
      expect(parseWKT(p.asText) is Point, true);
    });

    test("a measured point 3D point", () {
      var p = new Point(1,2, m: 3.1, z: 4);
      expect(p.asText, "POINT ZM (1 2 4 3.1)");
      expect(parseWKT(p.asText) is Point, true);
    });
  });

  group("geojson", () {
    test("- deserialize a point", () {
      var gjson = """
      {"type": "Point", "coordinates": [1,2]}
      """;
      var o = new Geometry.geojson(gjson);
      expect(o is Point, true);
      expect(o.x, 1);
      expect(o.y, 2);
    });
  });

  group("toDirectPosition2D -", () {
    test("of an non-empty point should work", () {
      var p = new Point(1,2);
      var pos = p.toDirectPosition2D();
      expect(pos, const DirectPosition2D(1,2));
    });

    test("throws error if point is empty", () {
      var p = new Point.empty();
      expect(() => p.toDirectPosition2D(), throwsStateError);
    });
  });
}

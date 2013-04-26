library test_geometry_collection;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
import "package:meta/meta.dart";
import "dart:json" as json;

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


main() {
  group("constructors -", () {
    test("create an empty collection", () {
      var g = new GeometryCollection.empty();
      expect(g.isEmpty, true);
    });

    test("create a geometry collectioin with a point and a line string", () {
      var p = new Point(1,2);
      var ls = new LineString([new Point(1,2), new Point(3,4)]);
      var g = new GeometryCollection([p,ls]);
      expect(g.isEmpty, false);
      expect(g.length, 2);
    });

    test("from WKT - empty collection", () {
      var g = new GeometryCollection.wkt("geometrycollection empty");
      expect(g.isEmpty, true);
    });

    test("from WKT - non empty collection", () {
      var wkt = """geometrycollection (
         point (1 2),
         linestring (1 2, 3 4, 5 6)
      )
      """;
      var g = new GeometryCollection.wkt(wkt);
      expect(g.isEmpty, false);
      expect(g.length, 2);
      expect(g.first.runtimeType, Point);
      expect(g[1].runtimeType, LineString);
    });

  });
  /* ----------------------------------------------------------------- */
  group("geojson -", () {
    test("- deserialize a GeometryCollection", () {
      var gjson = """
      {"type": "GeometryCollection", "geometries": [
        {"type":"Point", "coordinates":[1,2]},
        {"type":"MultiPoint", "coordinates": [[1,2],[3,4]]},
        {"type":"LineString", "coordinates": [[1,2],[3,4],[5,6],[7,8]]}
        ]
      }
      """;
      var o = parseGeoJson(gjson);
      expect(o is GeometryCollection, true);
      o = (o as GeometryCollection);
      expect(o.length, 3);
      expect(o[0] is Point, true);
      expect(o[1] is MultiPoint, true);
      expect(o[2] is LineString, true);
    });
  });
}
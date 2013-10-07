library test_multipoint;

import "dart:collection";
import "package:unittest/unittest.dart";
import "package:meta/meta.dart";
import "dart:convert";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/wkt.dart";
part "../lib/src/geojson.dart";
part "../lib/src/direct_position.dart";

main() {
  group("constructor - ", () {
    test("empty", () {
      var mp = new MultiPoint.empty();
      expect(mp.isEmpty, true);
    });

    test("null point list", () {
      var mp = new MultiPoint(null);
      expect(mp.isEmpty, true);
    });

    test("empty point list", () {
      var mp = new MultiPoint([]);
      expect(mp.isEmpty, true);
    });

    test("multiplie points", () {
      var points = [
        new Point(11,12),
        new Point(21,22),
        new Point(31,32)
      ];
      var mp = new MultiPoint(points);
      expect(mp.isEmpty, false);
      expect(mp.length, 3);
    });

    test("from wkt - empty multipoint", () {
      var mp = new MultiPoint.wkt("multipoint empty");
      expect(mp.isEmpty, true);
    });

    test("from wkt - two points", () {
      var mp = new MultiPoint.wkt("multipoint ((1 2), (3 4))");
      expect(mp.length, 2);
    });

    test("from wkt - don't accept wrong tagged WKT object", () {
      var mp;
      expect(() => new MultiPoint.wkt("point (1 2)"),
          throwsA(new isInstanceOf<WKTError>()));
    });
  });

  group("iterable -", () {
    test("iterable interface should work", () {
      var points = [
        new Point(11,12),
        new Point(21,22),
        new Point(31,32)
      ];
      var mp = new MultiPoint(points);
      expect(mp.first.x, 11);
      expect(mp.last.y, 32);
      expect(mp.firstWhere((p) => p.x == 21).y, 22);
      expect(mp[1].z, null);
    });
  });

  group("isSimple -", () {
    test("an empty multipoint is simple", () {
      var mp = new MultiPoint.empty();
      expect(mp.isSimple, true);
    });

    test("a multipoint with no duplicate points is simple", () {
      var points = [
                    new Point(11,12),
                    new Point(21,22),
                    new Point(31,32)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isSimple, true);
    });

    test("first two points are duplicates -> not simple", () {
      var points = [
                    new Point(11,12),
                    new Point(11,12),
                    new Point(21,22),
                    new Point(31,32)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isSimple, false);
    });

    test("last two points are duplicates -> not simple", () {
      var points = [
                    // deliberatly chaning the "order" of points in
                    // order to test internal sorting
                    new Point(31,32),
                    new Point(31,32),
                    new Point(11,12),
                    new Point(21,22)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isSimple, false);
    });

    test("arbitray points are duplicates -> not simple", () {
      var points = [
                    // deliberatly chaning the "order" of points in
                    // order to test internal sorting
                    new Point(31,32),
                    new Point(11,12),
                    new Point(11,12),
                    new Point(21,22)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isSimple, false);
    });
  });

  group("is3D -", () {
    test("an empty multipoint isn't 3D", () {
      var mp = new MultiPoint.empty();
      expect(mp.is3D, false);
    });

    test("a multipoint consisting of 3D points only is 3D", () {
      var points = [
                    new Point(11,12, z:13),
                    new Point(21,22, z:23),
                    new Point(31,32, z:33)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.is3D, true);
    });


    test("a multipoint with at least one xy-point isn't 3D", () {
      var points = [
                    new Point(11,12, z:13),
                    new Point(21,22),
                    new Point(31,32, z:33)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.is3D, false);
    });
  });


  group("isMeasured -", () {
    test("an empty multipoint isn't measured", () {
      var mp = new MultiPoint.empty();
      expect(mp.isMeasured, false);
    });

    test("a multipoint consisting of measured points only is measured", () {
      var points = [
                    new Point(11,12, m:13),
                    new Point(21,22, m:23),
                    new Point(31,32, m:33)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isMeasured, true);
    });


    test("a multipoint with at least one unmeasured point isn't measured", () {
      var points = [
                    new Point(11,12, m:13),
                    new Point(21,22),
                    new Point(31,32, m:33)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.isMeasured, false);
    });
  });

  group("boundary -", () {
    test("the boundary of an empty multipoint is empty", () {
      var mp = new MultiPoint.empty();
      expect(mp.boundary.isEmpty, true);
    });

    test("the boundary of any multipoint is empty", () {
      var points = [
                    new Point(11,12),
                    new Point(21,22, m:23),
                    new Point(31,32, z:33)
                    ];
      var mp = new MultiPoint(points);
      expect(mp.boundary.isEmpty, true);
    });
  });


  group("asText -", () {
    test("of an empty multipoint", () {
      var mp = new MultiPoint.empty();
      mp = parseWKT(mp.asText);
      expect(mp.isEmpty, true);
    });

    test("of 3D multipoint with 2 points", () {
      var points = [
          new Point(21,22, z:23),
          new Point(31,32, z:33)
      ];
      var mp = new MultiPoint(points);
      mp = parseWKT(mp.asText);
      expect(mp.length, 2);
      expect(mp.is3D, true);
    });
  });

  group("geojson -", () {
    test("deserialize a multipoint", () {
      var gjson = """
      {"type": "MultiPoint", "coordinates": [[1,2], [3,4], [5,6]]}
      """;
      var o = parseGeoJson(gjson);
      expect(o is MultiPoint, true);
      expect(o.length, 3);
      for (int i=0; i<o.length; i++) {
        expect(o[i] is Point, true);
      }
      expect([o[0].x, o[0].y], [1,2]);
      expect([o[1].x, o[1].y], [3,4]);
      expect([o[2].x, o[2].y], [5,6]);
    });
  });
}


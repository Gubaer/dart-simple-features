library test_multipoint;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart";
import "package:meta/meta.dart";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/multipoint.dart";

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


}


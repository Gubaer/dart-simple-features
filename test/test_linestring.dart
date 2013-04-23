library test_linestring;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart";
import "package:meta/meta.dart";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multipoint.dart";

main() {
  group("constructor -", () {
    test("empty() constructor", () {
      var ls = new LineString.empty();
      expect(ls.isEmpty, true);
    });
    test("null list leads to empty linestring", () {
      var ls = new LineString(null);
      expect(ls.isEmpty, true);
    });
    test("empty list leads to empty linestring", () {
      var ls = new LineString([]);
      expect(ls.isEmpty, true);
    });

    test("only one point isn't allowed", () {
      var p = new Point(1,2);
      expect(() => new LineString([p]),
          throwsA(new isInstanceOf<ArgumentError>()));
    });
    test("null points aren't allowed", () {
      var p = new Point(1,2);
      expect(() => new LineString([p,null,null]),
          throwsA(new isInstanceOf<ArgumentError>()));
    });
    test("2 points and more are allowed", () {
      var p = new Point(1,2);
      var q = new Point(3,4);
      var ls = new LineString([p,q]);
      expect(ls.length, 2);
    });
  });

  group("isEmpty -", () {
    test("should be true for an empty linestring", () {
      var ls = new LineString.empty();
      expect(ls.isEmpty, true);
    });

    test("should be false for an non-empty linestring", () {
      var ls = new LineString([new Point(1,2), new Point(3,4)]);
      expect(ls.isEmpty, false);
    });
  });

  group("geometryType -", () {
    test("should be LineString", () {
      var ls = new LineString.empty();
      expect(ls.geometryType, "LineString");
    });
  });

  group("dimension -", () {
    test("should be 1", () {
      var ls = new LineString.empty();
      expect(ls.dimension, 1);
    });
  });

  group("is3D -", () {
    test("should be true if all points are 3D", () {
      var ls = new LineString([
        new Point(11,12,z:13),
        new Point(21,22,z:23),
        new Point(31,32,z:33)
      ]);
      expect(ls.is3D, true);
    });
    test("should be false if any points isn't 3D", () {
      var ls = new LineString([
        new Point(11,12,z:13),
        new Point(21,22),
        new Point(31,32,z:33)
      ]);
      expect(ls.is3D, false);
    });
  });

  group("isMeasured -", () {
    test("should be true if all points are measured", () {
      var ls = new LineString([
        new Point(11,12,m:13),
        new Point(21,22,m:23),
        new Point(31,32,m:33)
      ]);
      expect(ls.isMeasured, true);
    });
    test("should be false if any points isn't measured", () {
      var ls = new LineString([
        new Point(11,12,m:13),
        new Point(21,22),
        new Point(31,32,m:33)
      ]);
      expect(ls.isMeasured, false);
    });
  });

  group("isClosed -", () {
    test("en empty linestring isn't closed", () {
      var ls = new LineString.empty();
      expect(ls.isClosed, false);
    });
    test("a linestring with different start and end point isn't closed", () {
      var ls = new LineString([
        new Point(11,12),
        new Point(21,22),
        new Point(31,32)
      ]);
      expect(ls.isClosed, false);
    });
    test("a linestring with the same start end point is closed", () {
      var ls = new LineString([
        new Point(11,12),
        new Point(21,22),
        new Point(11,12)
      ]);
      expect(ls.isClosed, true);
    });
  });

  group("start point -", () {
    test("can be accessed using startPoint", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32)
      ]);
      expect(ls.startPoint.equals2D(new Point(11,12)), true);
    });
    test("can be accessed using first", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32)
      ]);
      expect(ls.first.equals2D(new Point(11,12)), true);
    });
    test("can be accessed using [0]", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32)
      ]);
      expect(ls[0].equals2D(new Point(11,12)), true);
    });
  });

  group("end point -", () {
    test("can be accessed using endPoint", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32)
      ]);
      expect(ls.endPoint.equals2D(new Point(31,32)), true);
    });
    test("can be accessed using last", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32)
      ]);
      expect(ls.last.equals2D(new Point(31,32)), true);
    });
  });

  group("line -", () {
    test("a linestring with two points is a line", () {
      var ls = new Line([
           new Point(11,12),
           new Point(21,22)
      ]);
      expect(ls.length, 2);
    });
    test("a linestring with three points isn't a line", () {
      var ls;
      expect((){
        ls = new Line([
             new Point(11,12),
             new Point(21,22),
             new Point(31,32)
        ]);
        },
        throwsA(new isInstanceOf<ArgumentError>())
      );
    });
  });

  group("line -", () {
    test("a simple closed linestring with four points is a LinearRing", () {
      var ls = new LinearRing([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32),
           new Point(11,12)
      ]);
      expect(ls.length, 4);
    });
    test("a open linestring with four points isn't a LinearRing", () {
      var ls;
      expect((){
        ls = new Line([
             new Point(11,12),
             new Point(21,22),
             new Point(31,32),
             new Point(41,42)
        ]);
        },
        throwsA(new isInstanceOf<ArgumentError>())
      );
    });
    test("a non simple linestring isn't a LinearRing", () {
      //TODO: test for simplicity not implemented yet
    });
  });

  group("boundary -", () {
    test("the boundary of an empty line is empty", () {
      var ls = new LineString.empty();
      expect(ls.boundary.isEmpty, true);
    });
    test("the boundary of a closed line string is empty", () {
      var ls = new LineString([
           new Point(11,12),
           new Point(21,22),
           new Point(31,32),
           new Point(41,42),
           new Point(11,12)
      ]);
      expect(ls.boundary.isEmpty, true);
    });
    test("the boundary of an open linestring consists of the endpoints", () {
      var ls = new LineString([
         new Point(11,12),
         new Point(21,22),
         new Point(31,32),
         new Point(41,42)
     ]);
      expect(ls.boundary.isEmpty, false);
      expect(ls.boundary.length, 2);
      expect(ls.boundary.first.x, 11);
      expect(ls.boundary.last.y, 42);
    });
  });
}


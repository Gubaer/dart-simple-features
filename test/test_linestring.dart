library test_linestring;

import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
import "package:meta/meta.dart";
import "dart:convert";
import "package:avl_tree/avl_tree.dart";
import "dart:math" as math;
import "package:log4dart/log4dart.dart";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/wkt.dart";
part "../lib/src/geojson.dart";
part "../lib/src/direct_position.dart";
part "../lib/src/line_intersection.dart";

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

    test("reject linestrings with identical consequtive points", () {
      expect(() => new LineString([new Point(0,0), new Point(1,1),
                                   new Point(1,1), new Point(2,2)]),
          throwsA(new isInstanceOf<ArgumentError>()));
    });

  });

  group("creating a ring -", () {
    test("from a closed, simple line string should work", () {
      var points  = [
         new Point(0,0),
         new Point(1,0),
         new Point(1,1),
         new Point(0,1),
         new Point(0,0)
      ];
      // should work
      var ls = new LineString.ring(points);
      expect(ls.length, 5);
    });

    test("from an open line string should fail", () {
      var points  = [
         new Point(0,0),
         new Point(1,0),
         new Point(1,1),
         new Point(0,1)
      ];
      expect(
          () => new LineString.ring(points),
          throwsArgumentError
      );
    });

    test("from a non simple, closed line string should fail", () {
      var points  = [
         new Point(0,0),
         new Point(2,0),
         new Point(2,2),
         new Point(3,1), // intersects with another segment
         new Point(0,0)
      ];
      expect(
          () => new LineString.ring(points),
          throwsArgumentError
      );
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

  group("linear ring -", () {
    test("a simple closed linestring with four points is a LinearRing", () {
      var ls = new LinearRing([
           new Point(0,0),
           new Point(5,0),
           new Point(5,5),
           new Point(0,5),
           new Point(0,0)
      ]);
      expect(ls.length, 5);
    });
    test("an open linestring with four points isn't a LinearRing", () {
      expect(() => new LinearRing([
             new Point(11,12),
             new Point(21,22),
             new Point(31,32),
             new Point(41,42)
        ]),
        throwsArgumentError
      );
    });
    test("a non simple linestring isn't a LinearRing", () {
      expect(() => new LinearRing([
               new Point(0,0),
               new Point(-1,1),
               new Point(1,1),
               new Point(0,0),    // self-intersection at this point
               new Point(-1,-1),
               new Point(-1,1),
               new Point(0,0)
           ]),
           throwsArgumentError
     );
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

  group("asText -", () {
    test("of an empty linestring", () {
      var ls = new LineString.empty();
      ls = parseWKT(ls.asText);
      expect(ls.isEmpty, true);
    });

    test("of a 2D linestring with three points", () {
      var ls = new LineString([
         new Point(11,12),
         new Point(21,22),
         new Point(31.5,32.6)
      ]);
      ls = parseWKT(ls.asText);
      expect(ls.length, 3);
      expect(ls.first.x, 11);
      expect(ls.last.y, 32.6);
    });

    test("of a 3D, measured linestring with three points", () {
      var ls = new LineString([
         new Point(11,12, z: 13, m: 14),
         new Point(21,22, z: 23, m: 24),
         new Point(31.5,32.6, z: 33.7, m: 34.8)
      ]);
      ls = parseWKT(ls.asText);
      expect(ls.length, 3);
      expect(ls.is3D, true);
      expect(ls.isMeasured, true);
      expect(ls.first.z, 13);
      expect(ls.last.m, 34.8);
    });
  });

  group("geojson", () {
    test("- LineString", () {
      var gjson = """
      {"type": "LineString", "coordinates": [[1,2], [3,4], [5,6]]}
      """;
      var o = parseGeoJson(gjson);
      expect(o is LineString, true);
      expect(o.length, 3);
      for (int i=0; i<o.length; i++) {
        expect(o[i] is Point, true);
      }
      expect([o[0].x, o[0].y], [1,2]);
      expect([o[1].x, o[1].y], [3,4]);
      expect([o[2].x, o[2].y], [5,6]);
    });
  });

  group("isSimple -", () {
    test("a linestring with two segments is simple", () {
      var ls = new LineString([new Point(0,0), new Point(1,1), new Point(2,2)]);
      expect(ls.isSimple, true);
    });

    test("a closed ring is simple", () {
      var ls = new LineString([
         new Point(0,0),
         new Point(0,1),
         new Point(1,0),
         new Point(0,0)
      ]);
      expect(ls.isSimple, true);
    });

    test("a 'butterfly' isn't simple", () {
      var ls = new LineString([
         new Point(0,0),
         new Point(-1,1),
         new Point(1,1),
         new Point(0,0),    // self-intersection at this point
         new Point(-1,-1),
         new Point(-1,1),
         new Point(0,0)
      ]);
      expect(ls.isSimple, false);
    });

    test("a line self intersecting between points isn't simple", () {
      var ls = new LineString([
         new Point(0,0),
         new Point(5,5),
         new Point(5,0),
         new Point(0,5)
      ]);
      expect(ls.isSimple, false);
    });

    test("another line with intersecting segments", () {
      var points  = [
           new Point(0,0),
           new Point(2,0),
           new Point(2,2),
           new Point(3,1), // intersects with another segment
           new Point(0,0)
      ];
      var ls = new LineString(points);
      expect(ls.isSimple, false);
    });

    test("a line with an overlapping segment isn't simple", () {
      var ls = new LineString([
         new Point(0,0),
         new Point(5,0),
         new Point(5,1),
         new Point(4,1),
         new Point(4,0), // overlaps with fist segment
         new Point(6,0)
      ]);
      expect(ls.isSimple, false);
    });
  });
}


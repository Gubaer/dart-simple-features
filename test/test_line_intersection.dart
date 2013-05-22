library test_line_intersection;

import "package:avl_tree/avl_tree.dart";
import "package:unittest/unittest.dart";
import "dart:collection";
import "dart:math" as math;
import "package:log4dart/log4dart.dart";

part "../lib/src/direct_position.dart";
part "../lib/src/line_intersection.dart";

main() {
  group("orientation -", () {
    test("counter-clock-wise", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,2);
      var o = _orientation(p,q,r);
      expect(o, 1);
    });
    test("clock-wise", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,-2);
      var o = _orientation(p,q,r);
      expect(o, -1);
    });

    test("collinear on half-line", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(20,0);
      var o = _orientation(p,q,r);
      expect(o, 0);
    });

    test("collinear on segment", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,0);
      var o = _orientation(p,q,r);
      expect(o, 0);
    });

    test("collinear on end point", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(10,0);
      var o = _orientation(p,q,r);
      expect(o, 0);
    });

    test("slight distortion from collinearity", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(20,1E10-10);
      var o = _orientation(p,q,r);
      expect(o, 1);
    });
  });

  group("segment relations -", () {
    test("two intersecting segments", () {
       var s1 = new LineSegment.from([0,0], [10,0]);
       var s2 = new LineSegment.from([5,5], [5,-5]);
       expect(s1.intersects(s2), true);
    });

    test("two non-intersecting segments", () {
       var s1 = new LineSegment.from([0,0], [10,0]);
       var s2 = new LineSegment.from([11,5], [11,-5]);
       expect(s1.intersects(s2), false);
    });

    test("two intersecting segments", () {
      var s1 = new LineSegment.from([0,0], [10,0]);
      var s2 = new LineSegment.from([9,10], [11,-10]);
      expect(s1.intersects(s2), true);
    });

    test("two non-intersecting segments", () {
      var s1 = new LineSegment.from([0,0], [10,0]);
      var s2 = new LineSegment.from([9,10], [12,-10]);
      expect(s1.intersects(s2), false);
    });

    test("two colinear segments, but no overlap", () {
      var s1 = new LineSegment.from([0,0], [1,0]);
      var s2 = new LineSegment.from([2,0], [3,0]);
      expect(s1.isColinear(s2), true);
      expect(s2.isColinear(s1), true);
      expect(s1.overlaps(s2), false);
      expect(s1.connectsTo(s2), false);
      expect(s1.intersects(s2), false);
    });

    test("two colinear segments, with overlap", () {
      var s1 = new LineSegment.from([0,0], [2,0]);
      var s2 = new LineSegment.from([1,0], [4,0]);
      expect(s1.isColinear(s2), true);
      expect(s2.isColinear(s1), true);
      expect(s1.overlaps(s2), true);
      expect(s1.connectsTo(s2), false);
      expect(s1.intersects(s2), false);
    });

    test("two colinear segments, not overlapping, but connecting", () {
      var s1 = new LineSegment.from([0,0], [2,0]);
      var s2 = new LineSegment.from([2,0], [4,0]);
      expect(s1.isColinear(s2), true);
      expect(s2.isColinear(s1), true);
      expect(s1.overlaps(s2), false);
      expect(s1.connectsTo(s2), true);
      expect(s1.intersects(s2), true);
    });

    test("two identical line segments", () {
      var s1 = new LineSegment.from([0,0], [2,0]);
      var s2 = new LineSegment.from([0,0], [2,0]);
      expect(s1.isColinear(s2), true);
      expect(s2.isColinear(s1), true);
      expect(s1.overlaps(s2), true);
      expect(s1.connectsTo(s2), false);
      expect(s1.intersects(s2), false);
    });
  });

  group("segment intersection -", () {
    test("two intersecting segments", () {
      var s1 = new LineSegment.from([-2,0], [2,0]);
      var s2 = new LineSegment.from([0,2], [0,-2]);
      var intersection = s1.intersectionWith(s2);
      expect(intersection, equals(new DirectPosition2D(0,0)));
    });

    test("two non-intersecting segments", () {
      var s1 = new LineSegment.from([-2,0], [2,0]);
      var s2 = new LineSegment.from([1,1], [5,5]);
      var intersection = s1.intersectionWith(s2);
      expect(intersection, isNull);
    });

    test("two colinear, overlapping segments", () {
      var s1 = new LineSegment.from([-2,0], [2,0]);
      var s2 = new LineSegment.from([0,0], [4,0]);
      var intersection = s1.intersectionWith(s2);
      expect(intersection, isNull);
    });

    test("two connected segments, colinaear, connected at end", () {
      var s1 = new LineSegment.from([-2,0], [2,0]);
      var s2 = new LineSegment.from([2,0], [4,0]);
      var intersection = s1.intersectionWith(s2);
      expect(intersection, new DirectPosition2D(2,0));
    });

    test("two connected segments, non-colienar, connected at start", () {
      var s1 = new LineSegment.from([-2,-2], [0,0]);
      var s2 = new LineSegment.from([0,0], [4,7]);
      var intersection = s1.intersectionWith(s2);
      expect(intersection, new DirectPosition2D(0,0));
    });
  });


  group("_EventQueue -", () {
    group("constructor -", () {
       test("create an event queue", () {
         var queue = new _EventQueue();
         expect(queue.isEmpty, true);
       });
    });

    group("addEvent -", () {
      test("add a non-exitent event", () {
        var queue = new _EventQueue();
        queue.addEvent(new DirectPosition2D(0,1));
        expect(queue.length, 1);
        expect(queue.first.pos.x, 0);
        expect(queue.first.pos.y, 1);
        expect(queue.first.segments.isEmpty, true);
      });

      test("add an already existing event", () {
        var queue = new _EventQueue();
        queue.addEvent(new DirectPosition2D(0,1));
        queue.addEvent(new DirectPosition2D(0,1));
        expect(queue.length, 1);
        expect(queue.first.pos.x, 0);
        expect(queue.first.pos.y, 1);
        expect(queue.first.segments.isEmpty, true);
      });
    });

    group("addLineSegmentEvents -", () {
      test("for a segment", () {
        var queue = new _EventQueue();
        var ls = new LineSegment(
            new DirectPosition2D(0,0),
            new DirectPosition2D(10,10)
        );
        queue.addLineSegmentEvents(ls);
        expect(queue.length, 2);
        expect(queue.first.pos.x, 10);
        expect(queue.first.pos.y, 10);
        expect(queue.first.segments.length, 1);
        expect(queue.first.segments.first, ls);
      });
    });


    group("unshift -", () {
      test("from a queue with one event", () {
        var queue = new _EventQueue();
        queue.addEvent(new DirectPosition2D(0,1));

        var event = queue.unshift();
        expect(event.pos.x, 0);
        expect(event.segments.isEmpty, true);
        expect(queue.isEmpty, true);
      });

      test("from a queue with one event", () {
        var queue = new _EventQueue();
        var ls = new LineSegment(
            new DirectPosition2D(0,0),
            new DirectPosition2D(10,10)
        );
        queue.addLineSegmentEvents(ls);
        var event = queue.unshift();
        expect(event.pos.x, 10);
        expect(event.segments.length, 1);
        expect(queue.length, 1);
        expect(queue.first.pos.x, 0);
        expect(queue.first.segments.isEmpty, true);
      });
    });
  });

  group("flatten -", () {
    Iterable flatten(e) => e is Iterable
        ? e.expand(flatten)
            : new List.filled(1, e);

      test("flatten", () {
        expect(flatten([1,2]).toList(), equals([1,2]));
        expect(flatten([1,[2,3],4]).toList(), equals([1,2,3,4]));
        expect(flatten([1,[2,[3,4,5], [6], []],7]).toList(), equals([1,2,3,4,5,6,7]));
      });
    });

  group("line intersection -", () {
    test("simple case - two lines intersecting in one point", () {
      var s1 = new LineSegment.from([-5,5], [5,-5]);
      var s2 = new LineSegment.from([2,2], [-2,-2]);
      var intersections = computeLineIntersections([s1,s2]);
      expect(intersections.length, 1);
      expect(intersections.first.pos, equals(new DirectPosition2D(0, 0)));
      expect(intersections.first.intersecting.toSet(), equals([s1, s2].toSet()));
    });


    test("simple case - two lines being connected in one point", () {
      var s1 = new LineSegment.from([0,0], [5,0]);
      var s2 = new LineSegment.from([5,0], [7,7]);
      var intersections = computeLineIntersections([s1,s2]);
      expect(intersections.length, 1);
      expect(intersections.first.pos, equals(new DirectPosition2D(5, 0)));
      expect(intersections.first.intersecting.toSet(), equals([s1, s2].toSet()));
    });

    test("two overlapping lines", () {
      var s1 = new LineSegment.from([5,5], [3,3]);
      var s2 = new LineSegment.from([4,4], [2,2]);
      var intersections = computeLineIntersections([s1,s2]);
      expect(intersections.length, 2);
      expect(intersections[0].pos, equals(new DirectPosition2D(4, 4)));
      expect(intersections[0].intersecting.toSet(), equals([s1, s2].toSet()));
      expect(intersections[1].pos, equals(new DirectPosition2D(3, 3)));
      expect(intersections[1].intersecting.toSet(), equals([s1, s2].toSet()));
    });
  });
}

library test_line_intersection;

import "package:unittest/unittest.dart";
import "../lib/line_intersection.dart";

main() {
  group("orientation -", () {
    test("counter-clock-wise", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,2);
      var o = orientation(p,q,r);
      expect(o, 1);
    });
    test("clock-wise", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,-2);
      var o = orientation(p,q,r);
      expect(o, -1);
    });

    test("collinear on half-line", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(20,0);
      var o = orientation(p,q,r);
      expect(o, 0);
    });

    test("collinear on segment", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(5,0);
      var o = orientation(p,q,r);
      expect(o, 0);
    });

    test("collinear on end point", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(10,0);
      var o = orientation(p,q,r);
      expect(o, 0);
    });

    test("slight distortion from collinearity", () {
      var p = new DirectPosition2D(0,0);
      var q = new DirectPosition2D(10,0);
      var r = new DirectPosition2D(20,1E10-10);
      var o = orientation(p,q,r);
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

  group("interesection with sweep line -", () {
    test("of a vertical line", () {
       var s1 = new LineSegment.from([0,0], [0,10]);
       var p = s1.intersectionWithSweepline(5);
       expect(p.x, 0);
       expect(p.y, 5);
    });

    test("of a line with positive slope", () {
      var s1 = new LineSegment.from([0,0], [6,6]);
      var p = s1.intersectionWithSweepline(3);
      expect(p.x, 3);
      expect(p.y, 3);
    });

    test("of a line with negative slope", () {
      var s1 = new LineSegment.from([0,0], [6,-6]);
      var p = s1.intersectionWithSweepline(-3);
      expect(p.x, 3);
      expect(p.y,-3);
    });
  });


  group("EventQueue -", () {
    group("constructor -", () {
       test("create an event queue", () {
         var queue = new EventQueue();
         expect(queue.isEmpty, true);
       });
    });

    group("addEvent -", () {
      test("add a non-exitent event", () {
        var queue = new EventQueue();
        queue.addEvent(new DirectPosition2D(0,1));
        expect(queue.length, 1);
        expect(queue.first.pos.x, 0);
        expect(queue.first.pos.y, 1);
        expect(queue.first.segments.isEmpty, true);
      });

      test("add an already existing event", () {
        var queue = new EventQueue();
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
        var queue = new EventQueue();
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
        var queue = new EventQueue();
        queue.addEvent(new DirectPosition2D(0,1));

        var event = queue.unshift();
        expect(event.pos.x, 0);
        expect(event.segments.isEmpty, true);
        expect(queue.isEmpty, true);
      });

      test("from a queue with one event", () {
        var queue = new EventQueue();
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

}


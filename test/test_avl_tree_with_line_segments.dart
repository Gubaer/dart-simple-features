library test_avl_tree_with_line_segments;

import "package:unittest/unittest.dart";
import "dart:math" as math;
import "../lib/avl_tree.dart";

int orientation(p, q, r) {
  var v = (p.x - r.x) * (q.y - r.y) - (q.x - r.x) * (p.y - r.y);
  if (v < 0) return -1;
  if (v == 0) return 0;
  return 1;
}


class Point implements Comparable<Point>{
  final num x, y;
  Point(this.x, this.y);

  int compareTo(other) {
    int ret = x.compareTo(other.x);
    return ret != 0 ? ret : y.compareTo(other.y);
  }
  String toString() => "($x, $y)";

  int get hashCode {
    const prime = 31;
    int result = 1;
    result = prime * result + x.hashCode;
    result = prime * result + y.hashCode;
    return result;
  }

  bool operator ==(other) => compareTo(other) == 0;
  bool operator <(other) => compareTo(other) == -1;
  bool operator <=(other) => compareTo(other) <= 0;
  bool operator >(other) => compareTo(other) == 1;
  bool operator >=(other) => compareTo(other) >= 0;
}

class LineSegment {
   final Point start;
   final Point end;
   LineSegment(this.start, this.end) {
     assert(start.y > end.y || (start.y == end.y && start.x < end.x));
   }

   bool hasEndpoint(p) => p == start || p == end;

   /**
    * This [LineSegment] is colinear with [other] iff this and [other]
    * lie on one straight line.
   */
  bool isColinearWith(LineSegment other) {
    var o1 = orientation(start, end, other.start);
    var o2 = orientation(start, end, other.end);
    return o1 == 0 && o2 == 0;
  }

  bool get isHorizontal => start.y == end.y;

  num _ccwOrientation = null;

  /**
   * Returns a number in the range [-1,1]. A horizontal line
   * has the orientation 1, a vertical line has the orientation 0.
   *
   * If -1 < value < 0, then the segment has a positive slope, the smaller
   * the value, the flatter the line segment.
   *
   * If 0 < value < 1, then the segment has a negative slope, the
   * higher the value, the latter the line segment.
   */
  num get counterclockwiseOrientation {
    if (_ccwOrientation!= null) return _ccwOrientation;
    if (isHorizontal) return 1;
    var dx = end.x - start.x;
    var dy = end.y - start.y;
    var c = math.sqrt(dx * dx + dy * dy);
    _ccwOrientation = dx / c;
    return _ccwOrientation;
  }

  toString() => "[ls: $start, $end]";
}

class SweepLineCompareFunction {
  Point event;
  SweepLineCompareFunction(this.event);

  int call(LineSegment value, LineSegment other) {
    // if other is left or right of the reference point
    // 'event' (which a priori is known to be on the segment
    // 'value' too), the ordering is clear
    var o = orientation(other.start, other.end, event);
    if (o != 0) return o;

    // otherwise 'value' and 'other' intersect in the
    // point event and are ordered according to the counter clockwise orientation
    // value. If both values are identical, then 'value'
    // and 'other' overlap (i.e. all their endpoints are colineaer and the
    // intersection isn't empty). They are considered to be in an
    // equivalence class.
    return value.counterclockwiseOrientation.compareTo(other.counterclockwiseOrientation);
  }
}

main() {
  group("counterclockwiseOrientation -", () {
    test("values are ordered as expected", () {
      var l;
      var values = [];

      // segments with positive slope, from flatter to steeper
      l  = new LineSegment(new Point(5,2), new Point(0,0));
      values.add(l.counterclockwiseOrientation);
      l  = new LineSegment(new Point(5,5), new Point(0,0));
      values.add(l.counterclockwiseOrientation);
      l  = new LineSegment(new Point(5,1000), new Point(0,0));
      values.add(l.counterclockwiseOrientation);

      // a vertical segments
      l  = new LineSegment(new Point(0,5), new Point(0,0));
      values.add(l.counterclockwiseOrientation);

      // segments with negative slope from steeper to flatter
      l  = new LineSegment(new Point(-5,5), new Point(0,0));
      values.add(l.counterclockwiseOrientation);
      l  = new LineSegment(new Point(-5,2), new Point(0,0));
      values.add(l.counterclockwiseOrientation);
      l  = new LineSegment(new Point(-5,0.01), new Point(0,0));
      values.add(l.counterclockwiseOrientation);

      // a horizontal segment
      l  = new LineSegment(new Point(0,0), new Point(5, 0));
      values.add(l.counterclockwiseOrientation);

      var sorted = new List.from(values);
      sorted.sort();
      expect(values, equals(sorted));
    });
  });

  group("inserting segments -", () {
    test("one segment", () {
      var tree = new AvlTree<LineSegment>();
      // a vertical line from point (0,5) to (0,0)
      var s = new LineSegment(new Point(0,5), new Point(0,0));
      // sweep line is at y = 5, event is (5,0)
      var compare = new SweepLineCompareFunction(new Point(5,0));
      tree.add(s, compare: compare);
      print(tree.inorder.toList());
    });

    test("two segments", () {
      var tree = new AvlTree<LineSegment>();
      var s1 = new LineSegment(new Point(0,5), new Point(5,0));
      var s2 = new LineSegment(new Point(0,5), new Point(-5,0));

      // sweep line is at y = 5, event is (0,5), there are two
      // segments s1,s2 starting at the event
      var compare = new SweepLineCompareFunction(new Point(0,5));
      expect(compare(s1, s2), 1);
      tree.add(s1, compare: compare);
      tree.add(s2, compare: compare);
      var leafs = tree.inorder.toList();
      // s2 < s1 because of the angle in which it intersects the sweep line
      expect(leafs[0], s2);
      expect(leafs[1], s1);
    });

    test("three segments, including a horizontal line", () {
      var tree = new AvlTree<LineSegment>();
      // s3 is a horizontal line
      var s3 = new LineSegment(new Point(0,5), new Point(5,5));
      var s1 = new LineSegment(new Point(0,5), new Point(5,0));
      var s2 = new LineSegment(new Point(0,5), new Point(-5,0));


      // sweep line is at y = 5, event is (0,5), there are two
      // segments s1,s2 starting at the event
      var compare = new SweepLineCompareFunction(new Point(0,5));
      tree.add(s3, compare: compare);
      tree.add(s1, compare: compare);
      tree.add(s2, compare: compare);
      var leafs = tree.inorder.toList();
      // s2 < s1 because of the angle in which it intersects the sweep line
      // s3 > s1, s3 > s2 because horizontal line segments are aways larger
      // than any other segments
      expect(leafs[0], s2);
      expect(leafs[1], s1);
      expect(leafs[2], s3);
    });
  });

  test("processing events in the Bentley-Ottman-Algorithm", () {
     // s1 and s2 intersect at (0,0)
     var s1 = new LineSegment(new Point(-5,5), new Point(5,-5));
     var s2 = new LineSegment(new Point(2,2), new Point(-2,-2));

     var tree = new AvlTree<LineSegment>();
     var compare = new SweepLineCompareFunction(null);


     /*
      * simulate steps in the Bentley-Ottman-Algorithm
      */

     // sweepline: y=5, event is (-5,-5)
     compare.event = new Point(-5,5);
       tree.add(s1, compare: compare);
       expect(tree.inorder, equals([s1]));

     // sweepline: y=2, event is (2,2)
     compare.event = new Point(2,2);
       tree.add(s2, compare: compare);
       expect(tree.inorder, equals([s1,s2]));

     // sweepline: y = 0, event is (0,0)
     compare.event = new Point(0,0);
       // remove the intersecting segments
       tree.remove(s1, compare: compare);
       tree.remove(s2, compare: compare);
       // add them again
       tree.add(s1, compare: compare);
       tree.add(s2, compare: compare);
       // now the order should be inverted
       expect(tree.inorder, equals([s2, s1]));

    // sweepline y=-2, event is (-2,-2)
    compare.event = new Point(-2,-2);
      tree.remove(s2, compare:compare);
      expect(tree.inorder, equals([s1]));

    // sweepline y=-5, event is (5, -5)
    compare.event = new Point(5, -5);
      tree.remove(s1, compare: compare);
      expect(tree.isEmpty, true);
  });
}
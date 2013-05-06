library line_intersection;

import "dart:collection";
import "simple_features.dart" show DirectPosition2D;
export "simple_features.dart" show DirectPosition2D;
import "dart:math" as math;
import "package:avl_tree/avl_tree.dart";

_require(cond, [msg]) {
    if (!cond) throw new ArgumentError(msg == null ? "" : msg);
}

/**
 * Computes the counterclockwise orientation of point [r] with respect
 * to the line given by the start and end points [p] and [q].
 *
 * Returns -1 if, if [r] is left to [p]-[q], 0 if is colinear with [p]-[q]
 * and 1 if it is to the right of [p]-[q].
 */
int orientation(DirectPosition2D p, DirectPosition2D q, DirectPosition2D r) {
  var v = (p.x - r.x) * (q.y - r.y) - (q.x - r.x) * (p.y - r.y);
  if (v < 0) return -1;
  if (v == 0) return 0;
  return 1;
}

/**
 * Represents closed line segment given by two 2D points.
 *
 * [start] is always the end point with the larger y-coordinate, or,
 * if y is equal, the lower x-coordinate. This is the order used
 * on events in the line intersection algorithm.
 *
 * LineSegments are never collapsed, they always have exactly two distinct
 * end points.
 */
class LineSegment {
  DirectPosition2D _start;
  DirectPosition2D _end;

  LineSegment(start, end) {
    _require(start != end, "line segments must not be collapsed: $start, $end");
    int c = comparePositionsInEventOrder(start, end);
    if (c <= 0) {
      _start = start;
      _end = end;
    } else {
      _start = end;
      _end = start;
    }
  }
  factory LineSegment.from(start, end) {
    _require(start is List);
    _require(end is List);
    _require(start.length == 2);
    _require(end.length == 2);
    return new LineSegment(
        new DirectPosition2D(start[0], start[1]),
        new DirectPosition2D(end[0], end[1])
    );
  }

  bool isEndPoint(DirectPosition2D p) => p == _start || p == _end;

  bool _fastExcludeIntersect(LineSegment other) {
    var minx = _start.x;
    var miny = _start.y < _end.y ? _start.y : _end.y;
    var maxx = _end.x;
    var maxy = _start.y >= _end.y ? _start.y : _end.y;
    if (other._start.x < minx && other._end.x < minx) return true;
    if (other._start.x > maxx && other._end.x > maxx) return true;
    if (other._start.y < miny && other._end.y < miny) return true;
    if (other._start.y > maxy && other._end.y > maxy) return true;
    return false;
  }

  /**
   * This [LineSegment] intersects with an [other] iff the intersection
   * consists of exactly one point.
   */
  bool intersects(LineSegment other) {
    if (this == other) return false;
    if (_fastExcludeIntersect(other)) return false;
    if (this.connectsTo(other) && !this.overlaps(other)) return true;
    var o1 = orientation(_start, _end, other._start);
    var o2 = orientation(_start, _end, other._end);
    if (o1 == o2) return false;
    o1 = orientation(other._start, other._end, _start);
    o2 = orientation(other._start, other._end, _end);
    return o1 != o2;
  }

  /**
   * This [LineSegment] connects to [other] iff the intersection consists
   * of exactly one end point.
   */
  bool connectsTo(LineSegment other) {
    return this != other
        && (other.isEndPoint(_start) || other.isEndPoint(_end));
  }

  /**
   * This [LineSegment] is colinear with [other] iff this and [other]
   * lie on a straight line.
   *
   */
  bool isColinear(LineSegment other) {
    var o1 = orientation(_start, _end, other._start);
    var o2 = orientation(_start, _end, other._end);
    return o1 == 0 && o2 == 0;
  }

  /**
   * This [LineSegment] and [other] overlap iff their intersection
   * consists of more than one point.
   */
  bool overlaps(LineSegment other) {
    if (this == other) return true;
    if (!isColinear(other)) return false;
    if (other.start < start && start < other.end) return true;
    if (other.start < end && end < other.end) return true;
    return false;
  }

  bool operator==(LineSegment other) =>
      start == other.start && end == other.end;

  bool get isHorizontal => _start.y == _end.y;

  DirectPosition2D intersectionWithSweepline(num y) {
    if (isHorizontal) throw new StateError("intersection with horizontal line not possible");
    // note: start.y > end.y is an invariant
    if (y > _start.y || y < _end.y) return null;
    if (y == _start.y) return _start;
    if (y == _end.y) return _end;
    var slope = 1 / slope;
    var dx = slope * (y - _start.y);
    return new DirectPosition2D(_start.x + dx, y);
  }

  DirectPosition2D intersectionWith(LineSegment other) {

  }

  double get slope => (_end.y - _start.y).toDouble() / (_end.x - _start.x).toDouble();

  DirectPosition2D get start => _start;
  DirectPosition2D get end => _end;

  /// caches the orientation value
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
}

/**
 * Represent an event to be processed in the Bentley-Ottman-Algorithm
 */
class Event implements Comparable<Event> {
  final DirectPosition2D pos;
  final List<LineSegment> segments;
  Event(this.pos, this.segments);

  int compareTo(Event other) => comparePositionsInEventOrder(pos, other.pos);
}

comparePositionsInEventOrder(p1, p2) {
  _require(p1 != null);
  _require(p2 != null);
  int c = p1.y.compareTo(p2.y);
  // The "higher" the event, the "earlier" it is processed
  // p1 < p2 if p1.y > p2.y
  // p1 > p2 if p1.y < p2.y
  if (c != 0) return -c;

  // The "more left" the event, the "earlier" it is processed
  return p1.x.compareTo(p2.x);
}

class EventQueue {
  AvlTree<Event> _events = new AvlTree<Event>();

  EventQueue();

  /**
   * Adds a new event at position [pos], unless there is already
   * an event at this position in the queue.
   */
  addEvent(DirectPosition2D pos) {
    _require(pos != null);
    _events.putIfAbsent(pos, () => new List<LineSegment>());
  }

  /**
   * Adds two events at the start and end position of [segment].
   */
  addLineSegmentEvents(LineSegment segment) {
    _require(segment != null);
    addEvent(segment.start);
    addEvent(segment.end);
    _events[segment.start].add(segment);
  }

  /**
   * Returns true if this queue is empty
   */
  bool get isEmpty => _events.isEmpty;

  /**
   * Removes the first event from the queue and returns it.
   * Throws an [StateError] if the queue is empty.
   */
  Event unshift() {
    if (this.isEmpty) throw new StateError();
    var pos = _events.firstKey();
    var segments = _events[pos];
    _events.remove(pos);
    return new Event(pos, segments);
  }

  /**
   * Returns the first event in this queue without removing it
   * from this queue.
   *
   * Throws a [StateError] if the queue is empty.
   */
  Event get first {
    if (this.isEmpty) throw new StateError("queue is empty");
    var pos = _events.firstKey();
    var segments = _events[pos];
    return new Event(pos, segments);
  }

  int get length => _events.length;
}

class SweepLineCompareFunction {
  DirectPosition2D event;
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

class LineIntersector {
  final AvlTree<LineSegment> sweepLine = new AvlTree<LineSegment>();
  final AvlTree<Event> eventQueue = new AvlTree<Event>();

  findEvent(LineSegment sl, LineSegment sr, DirectPosition2D pos) {

  }

  handleEvent(Event event) {
    var U = new List.from(event.segments, growable:false);
    var t = sweepLine.inorderAfter(predicate).takeWhile(containsP);
    var L = t.where(lowerEndPointIsP);
    var C = t - L;
    if (U.length + L.length + C.length > 0) {
      // report an intersection
    }
    var compare = new SweepLineCompareFunction(event.pos);

    L.forEach((s) => sweepLine.remove(s, compare: compare));
    U.forEach((s) => sweepLine.remove(s, compare: compare));

    U.forEach((s) => sweepLine.add(s, compare));
    C.forEach((s) => sweepLine.add(s, compare));

    compare = (LineSegment other) => orientation(other.start, other.end, event.pos);
    if (U.length + C.length != 0) {
      var sl = sweepLine.leftNeighbour(compare);
      var sr = sweepLine.rightNeighbour(compare);
      findEvent(sl, sr, event.pos);
    } else {

    }


  }
  run() {
    while(!eventQueue.isEmpty) {
      var event = eventQueue.smallest.first;
      eventQueue.remove(event);
      handleEvent(event);
    }
  }

}

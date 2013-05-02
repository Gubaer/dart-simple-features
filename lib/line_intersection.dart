library line_intersection;

import "dart:collection";
import "simple_features.dart" show DirectPosition2D;
export "simple_features.dart" show DirectPosition2D;

_require(cond, [msg]) {
    if (!cond) throw new ArgumentError(msg == null ? "" : msg);
}

int orientation(p, q, r) {
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
   * This [LineSegments] intersects with an [other] iff the intersection
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
   * This [LineSegment] conntects to [other] iff the intersection consists
   * of exactly one end point.
   */
  bool connectsTo(LineSegment other) {
    return this != other
        && (other.isEndPoint(_start) || other.isEndPoint(_end));
  }

  /**
   * This [LineSegment] is colinear with [other] iff this and [other]
   * lie on one straight line.
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
    // remember: start.y > end.y
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
}

class Event {
  final DirectPosition2D pos;
  final List<LineSegment> segments;
  Event(this.pos, this.segments);
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
  SplayTreeMap<DirectPosition2D, List<LineSegment>> _events
    = new SplayTreeMap(comparePositionsInEventOrder);

  EventQueue();

  /**
   * Adds a new event at position [pos], unless there is alread
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

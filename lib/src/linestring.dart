part of simple_features;

/// the singleton empty line string
final _EMPTY_LINESTRING = new LineString(null);

/**
 * A LineString is a curve with linear interpolation between points.
 *
 */
class LineString extends Geometry
  with IterableMixin<Point>, _GeometryContainerMixin {

  List<Point> _points;

  /**
   * Creates a new linestring.
   *
   * Creates an empty linestring if [points] is null or empty.
   *
   * Throws an [ArgumentError] if [points] contains only one
   * point or if it contains null values or empty points.
   */
  LineString(List<Point> points) {
    if (points == null || points.isEmpty) {
      _points = null;
    } else {
      _require(points.length >= 2,
          "illegal number of points, got ${points.length}");
      _require(points.every((p) => p != null && !p.isEmpty),
          "points must not contain null values or empty points");
      _points = new List.from(points,growable:false);
    }
  }

  /**
   * Creates an empty linestring.
   */
  factory LineString.empty() => _EMPTY_LINESTRING;

  Iterator<Point> get iterator =>
      _points == null ? [].iterator : _points.iterator;

  @override String get geometryType => "LineString";
  @override int get dimension => 1;

  /**
   * Replies the number of points in this linestring.
   *
   * See also [length]
   */
  @specification(name="numPoints()")
  int numPoints() => length;

  /**
   * Replies the n-th point this linestring.
   *
   * See also [elementAt]
   */
  @specification(name="pointN()")
  Point pointN(int n) => elementAt(n);

  /**
   * Replies the (spatial) length of this line string.
   */
  @specification(name="length()")
  //TODO: implement
  num get spatialLength {
    throw new UnimplementedError();
  }

  /**
   * Replies the start point of this linestring.
   *
   * See also the Dart'ish property [first].
   *
   * Throws a [StateError] if this linestring is empty.
   */
  @specification(name="StartPoint()")
  Point get startPoint => first;

  /**
   * Replies the end point of this linestring.
   *
   * See also the Dart'ish property [last].
   *
   * Throws a [StateError] if this linestring is empty.
   */
  @specification(name="EndPoint()")
  Point get endPoint => last;

  /**
   * Replies true if this linestring isn't empty and its
   * first and last points are equal (with respect to the xy-coordinates)
   */
  bool get isClosed {
    if (this.isEmpty) return false;
    return first.equals2D(last);
  }

  /**
   * Replies true if this linestring is closed and simple.
   *
   */
  //TODO: implement
  bool get isRing {
    throw new UnimplementedError();
  }
}


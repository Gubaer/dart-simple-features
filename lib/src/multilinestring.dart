part of simple_features;

final _EMPTY_MULTI_LINE_STRING = new MultiLineString(null);

/**
 * A MultiLineString is a MultiCurve whose elements are [LineString]s.
 */
class MultiLineString extends GeometryCollection{
  /**
   * Creates a multilinestring for a collection of [linestrings].
   *
   * If [linestrings] is null or empty, an empty [MultiLineString]
   * is created.
   */
  MultiLineString(Iterable<LineString> linestrings) : super(linestrings);

  /**
   * Creates an empty multilinestring.
   */
  factory MultiLineString.empty() => _EMPTY_MULTI_LINE_STRING;

  @override int get dimension => 1;
  @override String get geometryType => "MultiLineString";

  /**
   * This multilinestring is closed if all child line strings are
   * closed.
   */
  bool get isClosed => _geometries.every((g) => g.isClosed);

  /**
   * Replies the spatial length of this multilinestring.
   */
  @specification(name="length()")
  num get spatialLength {
    throw new UnimplementedError();
  }

  /**
   * The boundary of a [MultiLineString] consists of the boundary
   * points of the child geometries which occur an odd number of
   * times in the boundaries.
   */
  @override
  Geometry get boundary {
    var pointRefCounts = new Map<DirectPosition2D, int>();
    countPosition(pos) {
      if (pointRefCounts.containsKey(pos)) {
        pointRefCounts[pos] = pointRefCounts[pos] + 1;
      } else {
        pointRefCounts[pos] = 1;
      }
    }

    // count the number of occurences for each boundary point
    forEach((child) {
      if (child.isEmpty) return;
      child.boundary.forEach((p) {
        countPosition(new _DirectPosition2DImpl(p.x,p.y));
      });
    });

    // boundary points with odd occurences in the child boundaries
    // are considered to be boundary points of this MultiLineString
    // too
    var points = [];
    pointRefCounts.forEach((pos, count) {
      if (count %2 == 0) return;
      points.add(new Point(pos.x, pos.y));
    });
    return new MultiPoint(points);
  }
}
part of simple_features;

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
  MultiLineString.empty() : super.empty();

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
}
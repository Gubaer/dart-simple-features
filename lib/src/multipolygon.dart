part of simple_features;

final _EMPTY_MULTI_POLYGON = new MultiPolygon(null);

/**
 * A MultiPolygon is a MultiSurface whose elements are [Polygon]s.
 */
class MultiPolygon extends GeometryCollection {

  /**
   * Creates a multipolygon.
   *
   * For polygons, a set of geometric invariants should be true, see
   * the SFS:
   *
   * * the interiors of two polygons in this multi polygon may not intersect
   * * the boundaries of two polygons may not "cross" and if they touch, then
   *   ony at a finite number of points
   * * a multipolygon must not have cut lines, spikes or punctures
   *
   * Note, that none of these invariants are currently enforced when a
   * polygon is created.
   */
  MultiPolygon(Iterable<Polygon> polygons) : super(polygons);

  /**
   * Creates an empty multipolygon.
   */
  factory MultiPolygon.empty() => _EMPTY_MULTI_POLYGON;

  @override Geometry get boundary {
    if (this.isEmpty) return new MultiLineString.empty();
    return new MultiLineString(_geometries.expand((g) => g.boundary));
  }

  @override int get dimension => 2;
  @override String get geometryType => "MultiPolygon";

}
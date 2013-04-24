part of simple_features;

/**
 * A Polygon is a planar Surface defined by 1 exterior boundary and 0 or
 * more interior boundaries. Each interior boundary defines a hole in the
 * Polygon.
 */
class Polygon extends Surface {

  LineString _exterior;
  List<LineString> _interiors;

  /**
   * Creates a new polygon.
   *
   * [exteriorRing] must not be null. If [exteriorRing] is empty,
   * [interiorRings] must be null, the empty list, or consist of
   * empty [LinearRing]s only.
   *
   * [interiorRings] can be null. If it is a non-empty list, then it
   * must not contain null values.
   *
   * Note: According to the SFS, both the exterior and the interior must
   * be valid [LinearRing]s, i.e. they must be simple, closed [LineString]s.
   * Exterior and interior rings must not cross and a polygon must not have
   * cuts, spikes, punctures (see the SFS for examples). These restrictions
   * are currently not enforced when a [Polygon] is created.
   *
   * Throws [ArgumentError] if one of the preconditions is violated.
   */
  Polygon(LineString exteriorRing, Iterable<LineString> interiorRings) {
    _require(exteriorRing != null);
    //TODO: valdiate that exteriorRing is indeed a ring
    if (interiorRings == null) interiorRings = [];
    _require(interiorRings.every((r) => r != null),
        "interior rings must not be null"
    );
    if (exteriorRing.isEmpty) {
      _require(interiorRings.every((r) => r.isEmpty),
          "exterior ring is empty => all interior rings must be empty"
      );
      _exterior = null;
      _interiors = null;
      return;
    }
    _exterior = exteriorRing;
    _interiors = new List.from(interiorRings, growable: false);
    //TODO: check geometry of interiors. Must be valid rings, mutually not
    // intersection
    //TODO: check geometry of overall polygon. SFS mentions a set of edge
    // cases like spikes, cuts or punctures which are not allowed
  }

  /**
   * Creates a new empty polygon.
   */
  Polygon.empty(): _exterior=null, _interiors = null;

  /**
   * The exterior ring of this polygon.
   *
   * Replies an empty linestring if this polygon is empty.
   */
  @specification(name="exteriorRing()")
  LineString get exteriorRing => _exterior == null
    ? new LineString.empty()
    : _exterior;


  /**
   * The interior rings. Replies an empty iterable, if
   * this polygon doesn't have interior rings.
   */
  Iterable<LineString> get interiorRings => _interiors== null
      ? []
      : _interiors;

  /// the number of interior rings
  @specification(name="numInteriorRing()")
  int get numInteriorRing => _interiors == null
    ? 0
    : _interiors.length;

  /**
   * Replies the n-th interior ring.
   *
   * Throws a [RangeError] if [n] is out of range
   */
  @specification(name="interiorRingN()")
  LineString interiorRingN(int n) => interiorRings.elementAt(n);

  @override String get geometryType => "Polygon";

  /**
   * Replies true if this polygon isn't empty and if both the
   * exterior and each of the interior rings are 3D.
   */
  @override bool get is3D {
    bool ret = _exterior == null ? false : _exterior.is3D;
    if (interiorRings.length == 0) return ret;
    ret = ret && interiorRings.every((r) => r.is3D);
    return ret;
  }

  /**
   * Replies true if this polygon isn't empty and if both the
   * exterior and each of the interior rings are measured.
   */
  @override bool get isMeasured {
    bool ret = _exterior == null ? false : _exterior.isMeasured;
    if (interiorRings.length == 0) return ret;
    ret = ret && interiorRings.every((r) => r.isMeasured);
    return ret;
  }

  @override bool get isEmpty => _exterior == null;

  @override Geometry get boundary {
    if (isEmpty) return new MultiLineString.empty();
    if (interiorRings.isEmpty) return exteriorRing;
    var rings = [];
    rings.add(exteriorRing);
    rings.addAll(interiorRings);
    return new MultiLineString(rings);
  }
}
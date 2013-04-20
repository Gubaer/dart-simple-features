part of simple_features;

final _EMPTY_MULTIPOINT = new MultiPoint(null);

/**
 * A MultiPoint is a 0-dimensional GeometryCollection. The elements of a
 * MultiPoint are restricted to Points. The Points are not connected or
 * ordered in any semantically important way.
 */
class MultiPoint extends GeometryCollection {

  /**
   * Creates a new multipoint object [points].
   *
   * [points] must not include null values, otherwise throws an
   * [ArgumentError].
   *
   * if [points] is null or empty, then an empty multipoint object
   * is created.
   *
   * [points] don't have to be homogeneous with respect to the z- and
   * m-coordinate. You can mix xy-, and xy{z,m}-points in a multipoint.
   * However, [is3D] only returns true, iff all points have a z-coordinate.
   * Similary, [isMeasured] only returns true, iff all points have an
   * m-value.
   */
  MultiPoint(List<Point> points): super(points);

  /**
   * Creates an empty multipoint object.
   */
  factory MultiPoint.empty() =>_EMPTY_MULTIPOINT;

  @override int get dimension => 0;
  @override String get geometryType => "MultiPoint";
  @override bool get isValid => true;

  bool _isSimple = null;
  _computeIsSimple() {
    compare(p, q) {
      int c = p.x.compareTo(q.x);
      return c != 0 ? c : p.y.compareTo(q.y);
    }
    checkDuplicate(last, that) {
      if (last == null) return that; // that is the first element
      if (last == false) return false; // we already have a duplicate
      if (last.x == that.x && last.y == that.y) {
        // now we have a duplicate
        return false;
      }
      // no duplicate -> that becomes last in the next step
      return that;
    }
    if (this.isEmpty) {
      _isSimple = true;
      return;
    }
    _geometries.sort(compare);
    var ret = _geometries.fold(null, checkDuplicate);
    _isSimple = !(ret == false);
  }

  /**
   * A MultiPoint is simple if no two points are identical.
   *
   * The value of this property is computed upon first access
   * and then cached. Subsequent reads of the property
   * efficiently reply the cached value.
   */
  @override
  bool get isSimple {
    if (_isSimple == null) _computeIsSimple();
    return _isSimple;
  }
}

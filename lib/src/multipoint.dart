part of simple_features;

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
   * Similary, [isMeasured] only returns true, iff all points have a
   * m-coordinate.
   */
  MultiPoint(List<Point> points): super(points) {
    _require(every((p) => p != null));
  }

  /**
   * Creates an empty multipoint object.
   */
  MultiPoint.empty() : super.empty();

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
    // Don't remove 'this.', see
    // https://code.google.com/p/dart/issues/detail?id=10041
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

  bool _is3D = null;
  _computeIs3D() {
    if (this.isEmpty) {
      _is3D = false;
    } else {
      _is3D = firstWhere((p) => !p.is3D,
          orElse: () => null) == null;
    }
  }

  /**
   * A MultiPoint is considered 3D if *every* point in the collection
   * has a non-null z-component.
   *
   * The value of this property is computed upon first access and then
   * cached. Subsequent reads of the property efficiently reply the cached
   * value.
   */
  @override
  bool get is3D {
    if (_is3D == null) _computeIs3D();
    return _is3D;
  }

  bool _isMeasured = null;
  _computeIsMeasured() {
    if (this.isEmpty) {
      _isMeasured = false;
    } else {
      _isMeasured = firstWhere((p) => !p.isMeasured,
          orElse: () => null) == null;
    }
  }

  /**
   * A MultiPoint is considered *measured* if *every* point in the collection
   * has an m-component.
   *
   * The value of this property is computed upon first access and then
   * cached. Subsequent reads of the property efficiently reply the cached
   * value.
   */
  @override
  bool get isMeasured {
    if (_isMeasured == null) _computeIsMeasured();
    return _isMeasured;
  }
}

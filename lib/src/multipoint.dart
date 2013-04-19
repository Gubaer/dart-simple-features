part of simple_features;

/**
 * A MultiPoint is a 0-dimensional GeometryCollection. The elements of a
 * MultiPoint are restricted to Points. The Points are not connected or
 * ordered in any semantically important way.
 */
class MultiPoint extends GeometryCollection {

  /**
   * Creates a new multi point collection holding [points].
   */
  MultiPoint(List<Point> points): super(points);

  /**
   * Creates a new empty multi point collection.
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
    reduce(last, that) {
      if (last == null) return that;
      if (last == false) return false;
      if (last.x == that.x && last.y == that.y) return false;
      return that;
    }
    if (isEmpty) return true;
    _geometries.sort(compare);
    var ret = _geometries.fold(null, reduce);
    _isSimple = ret == false;
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
    _is3D = firstWhere((p) => !p.is3D, () => null) == null;
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
}

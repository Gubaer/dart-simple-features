part of simple_features;

/**
 * A [GeometryCollection] is a geometric object that is a collection of
 * some number of geometric objects.
 *
 * It implements the accesor methods [numGeometries] and [getGeometryN]
 * which are specified in the SFS. In addition, it provides the more
 * Dart'ish [length] property and an overloaded index operator. It also
 * implements the [Iterable] interface.
 *
 */
//TODO: abstract class?
class GeometryCollection extends Geometry
  with IterableMixin<Geometry>, _GeometryContainerMixin {
  List<Geometry> _geometries;

  /**
   * Creates a geometry collection given a collection of
   * [geometries].
   */
  GeometryCollection(Iterable<Geometry> geometries) {
    if (geometries == null || geometries.isEmpty) {
      _geometries = null;
    } else {
      _geometries = new List<Geometry>.from(geometries, growable:false);
      _require(this.every((p) => p != null));
    }
  }
  /**
   * Creates an empty geometry collection.
   */
  GeometryCollection.empty(): this(null);

  /**
   * Replies the number of geometries in this collection.
   *
   * This getter is equivaled to the method `getNumGeometries()`
   * in the SFS, but see also [length].
   */
  @specification(name="getNumGeometries")
  int get numGeometries => length;

  /**
   * Replies the <em>n</em>-th geometry in this collection.
   *
   */
  @specification(name="getGeometryN")
  Geometry getGeometryN(int n) => elementAt(n);

  /**
   * Replies the <em>n</em>-th geometry in this collection.
   *
   * This is the Dart'ish implemenation of `getGeometryN()` using
   * operator overloading.
   */
  @specification(name="getGeometryN")
  operator [](int n) => elementAt(n);

  /// the iterator to access the geometry objects
  Iterator<Geometry> get iterator {
    if (_geometries == null) return [].iterator;
    else return _geometries.iterator;
  }
}

class _GeometryContainerMixin {
  bool _is3D = null;
  _computeIs3D() {
    if (this.isEmpty) {
      _is3D = false;
    } else {
      _is3D = this.firstWhere((p) => !p.is3D,
          orElse: () => null) == null;
    }
  }

  /**
   * A collection of geometries is considered 3D if *every* child geometry
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
   * A collection of geometries is considered *measured* if *every* child
   * geometry has an m-component.
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

  _Envelope _computeEnvelope() {
    if (this.isEmpty) return new _Envelope.empty();
    _Envelope e = new _Envelope.empty();
    forEach((p) => e.growTo(p));
    return e;
  }

  operator [](int n) => this.elementAt(n);
}



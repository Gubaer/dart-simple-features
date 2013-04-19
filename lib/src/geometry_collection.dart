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
class GeometryCollection extends Geometry with IterableMixin<Geometry> {
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



part of simple_features;

/**
 * The abstract base class for all geometries.
 */
abstract class Geometry {

  int _srid;

  /**
   * Creates a geometry from the WKT string [wkt].
   *
   * Throws a [WKTError] if [wkt] isn't a valid WKT geometry.
   */
  factory Geometry.wkt(String wkt) => parseWKT(wkt);


  /**
   * Creates a geometry from a GeoJSON string [json].
   *
   * Throws a  [FormatError] if [json] isn't valid.
   */
  factory Geometry.geojson(String json) => parseGeoJson(json);

  Geometry();

  /**
   * Returns 1 true if this geometric object is the empty Geometry.
   */
  @specification(name:"isEmpty()")
  bool get isEmpty;

  /**
   * Returns true if this geometric object has z coordinate values.
   */
  @specification(name:"is3D()")
  bool get is3D;

  /**
   * Returns true if this geometric object has m coordinate values.
   */
  @specification(name:"isMeasured()")
  bool get isMeasured;

  /**
   * Returns the closure of the combinatorial boundary of this geometric object
   */
  @specification(name:"boundary()")
  Geometry get boundary;

  /**
   *  Returns true if this geometric object has no anomalous geometric points,
   *  such as self intersection or self tangency.
   */
  @specification(name:"isSimple()")
  bool get isSimple;

  /**
   * Returns the name of the instantiable subtype of Geometry of which this
   * geometric object is an instantiable member. The name of the subtype of
   * Geometry is returned as a string.
   */
  @specification(name:"geometryType()")
  String get geometryType;

  /**
   * The inherent dimension of this geometric object, which must be less than
   * or equal to the coordinate dimension. In non-homogeneous collections,
   * this will return the largest topological dimension of the contained objects.
   */
  @specification(name:"dimension()")
  int get dimension;

  /**
   * Returns the Spatial Reference System ID for this geometric object.
   */
  @specification(name:"srid()")
  int get SRID => _srid;

  /**
   * the Spatial Reference System ID for this geometric object.
   */
  set SRID(int value) => _srid = value;

  _Envelope get _envelope {
    if (_cachedEnvelope == null) {
      _cachedEnvelope = _computeEnvelope();
    }
    return _cachedEnvelope;
  }

  _Envelope _cachedEnvelope;
  _Envelope _computeEnvelop();

  /**
   * A WKT representation of the geometry
   */
  @specification(name:"asText()")
  String get asText {
    var buffer = new StringBuffer();
    var writer = new _WKTWriter(buffer);
    _writeTaggedWKT(writer, withZ: is3D, withM: isMeasured);
    return buffer.toString();
  }

  _writeTaggedWKT(writer, {bool withZ: false, bool withM: false});
}


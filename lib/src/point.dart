part of simple_features;

class Point extends Geometry {

  //TODO: z and m mostly unused. More efficient layout?
  //Using a List<num>, similar to jts? Using decicated subclasses?
  //
  /// the x-coordinate. null, if this point [isEmpty]
  final num x;
  /// the y-coordinate. null, if this point [isEmpty]
  final num y;
  /// the z coordinate. null, if missing
  final num z;
  /// the measurement value. null, if missing
  final num m;

  /**
   * Creates an empty point.
   *
   * [x], [y], [z], and [m] of an empty point are null.
   */
  Point.empty(): x=null, y=null, z = null, m = null;

  /**
   * Creates a point with coordinates [x], [y], and
   * (optionally) [z]. The point can be a assigned an
   * optional measurement value [m].
   */
  Point(this.x, this.y, {this.z, this.m}){
    _require(x != null);
    _require(y != null);
  }

  /**
   * Creates a new point from the WKT string [wkt].
   *
   * Throws a [WKTError] if [wkt] isn't a valid representation of
   * a [Point].
   */
  factory Point.wkt(String wkt) {
    var p = parseWKT(wkt);
    if (p is! Point) {
      throw new WKTError("WKT string doesn't represent a Point");
    }
    return p;
  }

  /**
   * Creates a new point from a list of point values.
   *
   * [values] is a list with either 2 or 4 elements, otherwise an
   * [ArgumentError] is thrown.
   *
   * * [x,y] - an xy-point.
   * * [x,y,z,m] - an xy-point with an z- and/or m-coordinate, if
   *   the 3d and/or the 4th element isn't null.
   *
   * x and y must be a [num], otherwise an [ArgumentError] is thrown.
   * z and m must be a [num] or null, otherwise an [ArgumentError] is thrown.
   */
  factory Point.from(List<num> values) {
    _require(values is List);
    _require(values.length == 2 && values.length == 4);
    _require(values.take(2).every((v) => v is num));
    _require(values.skip(2).every((v) => v is num || v == null));
    var x = values[0];
    var y = values[1];
    var z = values[2];
    var m = values[3];
    return new Point(x,y, m:m, z:z);
  }

  @override bool get isEmpty => x == null || y == null;

  @override bool get is3D => z != null;

  @override bool get isMeasured => m != null;

  _writeCoordinates(writer, {bool withZ:false, bool withM: false}) {
    writer
      ..position(x)
      ..blank()
      ..position(y);

    if (withZ) {
      writer
        ..blank()
        ..position(z);
    }
    if (withM) {
      writer
        ..blank()
        ..position(m);
    }
  }

  @override
  _writeTaggedWKT(writer, {bool withZ: false, bool withM: false}){
    writer.write("POINT");
    writer.blank();
    if (!isEmpty) {
      writer.ordinateSpecification(withZ: withZ, withM: withM);
    }
    if (this.isEmpty) {
      writer.empty();
    } else {
      writer.lparen();
      _writeCoordinates(writer, withZ: is3D, withM: isMeasured);
      writer.rparen();
    }
  }

  /**
   * The boundary of a point is the empty [GeometryCollection].
   *
   * Note: According to the SFS the boundary of a [Point] is the
   * empty set. Like the Java Topology Suite we reply an empty
   * [GeometryCollection], not an empty [Point].
   */
  @override Geometry get boundary => new GeometryCollection.empty();
  @override bool get isSimple => true;
  @override String get geometryType => "Point";
  @override int get dimension => 0;


  @override
  _Envelope _computeEnvelope() {
    if (isEmpty) return new _Envelope.empty();
    return new _Envelope.collapsed(x, y);
  }

  /**
   * Replies true if the (x,y)-coordinates of this point are
   * equal to the (x,y)-coordinates of [other].
   *
   * Replies false if [other] is null.
   */
  bool equals2D(Point other) {
    if (other == null) return false;
    return x == other.x && y == other.y;
  }

  /**
   * Returns [DirectPosition2D] given by the [x] and [y] coordinates of
   * this point.
   *
   * Throws [StateError] if this point [isEmpty].
   */
  DirectPosition2D toDirectPosition2D() {
    if (isEmpty) throw new StateError("not supported on empty point");
    return new DirectPosition2D(x,y);
  }
}


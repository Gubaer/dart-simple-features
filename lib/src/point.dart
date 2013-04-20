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

  @override
  String get asText {
    //TODO: introduce a WKT writer, simlar to the JTS library
    var buffer = new StringBuffer();
    buffer.write("point ");
    if (z != null) buffer.write("z");
    if (m != null) buffer.write("m");
    if (isEmpty) {
      buffer.write(" empty");
      return buffer.toString();
    }
    buffer.write(" ( ");
    buffer..write(x);
    buffer..write(", ")..write(y);
    if (z != null) buffer..write(", ")..write(z);
    if (m != null) buffer..write(", ")..write(m);
    buffer.write(")");
    return buffer.toString();
  }
  /// the boundary of a point is the empty set, that is, null
  @override Geometry get boundary => null;
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
}


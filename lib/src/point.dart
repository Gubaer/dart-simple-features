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
   * [values] is a list with either 2, 3, or 4 numbers.
   *
   * If [values] has two elements, a [Point] with an x- and y-coordinate is
   * created.
   *
   * If [values] has four elements, a [Point] with an x-, a y-, and a
   * z-coordinate is created. The fourth element is considered the
   * m-values.
   *
   * If [values] has three elements, either [withZ] or [withM] must be
   * set. Depending on the supplied flag, the third element is considered
   * as z- or as m-value.
   *
   */
  factory Point.from(List<num> values, {bool withZ: false, bool withM: false}) {
    _require(values is List);
    _require(values.length >= 2 && values.length <= 4);
    _require(values.every((v) => v is num));
    if (values.length == 2) {
      return new Point(values[0], values[1]);
    } else if (values.length == 4) {
      return new Point(values[0], values[1], z: values[2], m: values[3]);
    } else {
      _require(withZ || withM,
          "requires either withZ or withM for list with 3 values");
      if (withZ) {
        return new Point(values[0], values[1], z: values[2]);
      } else if (withM) {
        return new Point(values[0], values[1], m: values[2]);
      }
    }
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
}


part of simple_features;

abstract class Geometry {

  int _srid;

  factory Geometry.wkt(source) {
  }

  factory Geometry.json(source) {
  }

  Geometry();

  bool get isEmpty;
  bool get is3D;
  bool get isMeasured;
  Geometry get boundary;
  bool get isSimple;
  bool get isValid;
  String get geometryType;
  int get dimension;

  int get SRID => _srid;
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
  String get asText {
    var buffer = new StringBuffer();
    var writer = new _WKTWriter(buffer);
    _writeTaggedWKT(writer, withZ: is3D, withM: isMeasured);
    return buffer.toString();
  }

  _writeTaggedWKT(writer, {bool withZ: false, bool withM: false});
}


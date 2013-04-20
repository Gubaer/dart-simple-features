part of simple_features;

abstract class Geometry {

  int _srid;

  factory Geometry.wkt(source) {
  }

  factory Geometry.json(source) {
  }

  Geometry();

  bool get isEmpty;
  String get asText;
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
}


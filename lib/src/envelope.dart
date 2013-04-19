part of simple_features;

class _Envelope {
  final num minx;
  final num miny;
  final num maxx;
  final num maxy;

  _Envelope(this.minx, this.miny, this.maxx, this.maxy);

  _Envelope.empty() : this(null, null, null, null);

  _Envelope.collapsed(num minx, num miny) : this(minx, miny, minx,miny);

  bool get isEmpty => minx == null;

  Geometry toGeometry() {
    if (isEmpty) return new Point.empty();
    if (minx == maxx && miny == maxy) return new Point(minx, maxy);

    //TODO: implement other kind of envelops
    throw new UnimplementedError();
  }
}


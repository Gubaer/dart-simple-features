part of simple_features;

abstract class DirectPosition2D {
  num get x;
  num get y;
}

abstract class DirectPosition3D extends DirectPosition2D {
  num get z;
}

abstract class DirectPosition extends DirectPosition3D {
  num get m;
}

class _DirectPosition2DImpl implements DirectPosition2D, Comparable {
  final double x;
  final double y;
  const _DirectPosition2DImpl(num x, num y):
    this.x= x.toDouble(), this.y=y.toDouble();

  int compareTo(other) {
    _require(other is DirectPosition2D);
    int ret = x.compareTo(other.x);
    return ret != 0 ? ret : y.compareTo(y);
  }
  String toString() => "($x, $y)";

  bool operator ==(other) {
     if (other == null) return false;
     if (other is! DirectPosition2D) return false;
     return other.x == x && other.y == y;
  }

  int get hashCode {
    const prime = 31;
    int result = 1;
    result = prime * result + x.hashCode;
    result = prime * result + y.hashCode;
    return result;
  }
}
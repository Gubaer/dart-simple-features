part of simple_features;

class DirectPosition2D {
  final double x;
  final double y;
  const DirectPosition2D(num x, num y):
    this.x= x.toDouble(), this.y=y.toDouble();

  int compareTo(other) {
    _require(other is DirectPosition2D);
    int ret = x.compareTo(other.x);
    return ret != 0 ? ret : y.compareTo(other.y);
  }
  String toString() => "($x, $y)";

  int get hashCode {
    const prime = 31;
    int result = 1;
    result = prime * result + x.hashCode;
    result = prime * result + y.hashCode;
    return result;
  }

  bool operator ==(other) => compareTo(other) == 0;
  bool operator <(other) => compareTo(other) == -1;
  bool operator <=(other) => compareTo(other) <= 0;
  bool operator >(other) => compareTo(other) == 1;
  bool operator >=(other) => compareTo(other) >= 0;
}
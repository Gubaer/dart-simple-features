part of simple_features;

_require(cond, [msg]) {
  if (!cond) throw new ArgumentError(msg);
}

class ComparableMixin implements Comparable {
  bool operator ==(other) => compareTo(other) == 0;
  bool operator <(other) => compareTo(other) == -1;
  bool operator <=(other) => compareTo(other) <= 0;
  bool operator >(other) => compareTo(other) == 1;
  bool operator >=(other) => compareTo(other) > 0;
}
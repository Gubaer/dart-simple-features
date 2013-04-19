part of simple_features;

_require(cond, [msg]) {
  if (!cond) throw new ArgumentError(msg);
}


part of simple_features;

/**
 * Dimension provides constant for the dimensions in the DE-9IM.
 */
class Dimension implements Comparable<Dimension>{
  /// represents the dimension of a point
  static const P = const Dimension._(0, "0");

  /// represents the dimension of a line
  static const L = const Dimension._(1, "1");

  /// represents the dimension of a surface
  static const A = const Dimension._(2, "2");

  /// represents the dimension of an empty geometry
  static const FALSE = const Dimension._(-1, "F");

  /// represents the dimension of a non-empty geometry
  static const TRUE = const Dimension._(-2, "T");

  /// represents any dimension
  static const DONTCARE = const Dimension._(-3, "*");

  static const _dimensions = const [P, L, A, FALSE, TRUE, DONTCARE];

  /// the numeric value for the dimension
  final int dim;

  /// the string symbol for the dimension
  final String symbol;

  const Dimension._(this.dim, this.symbol);

  /**
   * Lookup the dimension for a given symbol.
   *
   * Throws an [ArgumentError] if now dimension is found
   */
  const factory Dimension.symbol(String symbol) {
    _require(symbol != null);
    symbol = symbol.toUpperCase();
    var d = _dimensions.where((dim) => dim.symbol == symbol);
    if (d == null) throw new ArgumentError("illegal symbol '$symbol'");
    return d;
  }

  String toString() => symbol;

  /**
   * Returns true if [pattern] matches with this dimension.
   */
  bool matches(Dimension pattern) {
    if (pattern == DONTCARE) return true;
    if (pattern == TRUE && (this == P || this == TRUE)) return true;
    if (pattern == FALSE && this == FALSE) return true;
    if (pattern == P && this == P) return true;
    if (pattern == L && this == L) return true;
    if (pattern == A && this == A) return true;
    return false;
  }
}

/**
 * Represents the possible locations in the DE-9IM.
 */
class Location {
  /// the interior of a geometry
  static const INTERIOR = const Location("i",0);

  /// the boundary of a geometry
  static const BOUNDARY = const Location("b",1);

  /// the exterior of a geometry
  static const EXTERIOR = const Location("e",2);

  static const NONE = const Location("_", -1);

  /// the symbol representing the location
  final String symbol;

  /// the column and row index of this dimensioin in the
  /// a De-9IM matrix
  final int index;
  const Location._(this.symbol, index);
  String toString() => symbol;
}

/**
 * An [IntersectionMatrix] represents a DE-9IM matrix.
 */
class IntersectionMatrix {

  /// the pattern for 'T*F**FFF*' (according to the JTD, the SFS says
  /// “TFFFTFFFT”)
  static const _EQUAL_PATTERN = const [
    const [TRUE,     DONTCARE, FALE    ],
    const [DONTCARE, DONTCARE, FALSE   ],
    const [FALSE,    FALSE,    DONTCARE]
  ];

  List<List<Dimension>> _values;

  _createValues() {
    values = new List<List<int>>.generate(3,
        (_) => new List<int>(3),
        growable:false
   );
    _values.forEach((l) => l.fill(0, l.length, Dimension.FALSE));
  }

  /**
   * Creates a new matrix whose elements are set to [Dimension.FALSE].
   */
  IntersectionMatrix() {
    _createValues();
  }

  /**
   * Creates a matrix according to the [pattern].
   */
  IntersectionMatrix.pattern(String pattern) {
    _require(pattern != null);
    pattern = pattern.trim();
    _require(pattern.length == 9);
    values = new List<List<int>>.generate(3,
        (_) => new List<int>(3),
        growable:false
    );
    pattern = pattern.trim();
    List<Dimension> dims = pattern.split("").map(
       (s) => const Dimension.symbol(s));
    for(int n= 0; n<9; n++) {
      final i = n ~/ 3;
      final j = n % 3;
      _values[i][j] = dims[n];
    }
  }

  /**
   * Returns the [Dimension] in the matrix cell ([row], [col]).
   */
  Dimension get(Location row, Location col) => _values[row.index][col.index];

  /**
   * Sets the [value] in the matrix cell ([row], [col]).
   */
  set(Location row, Location col, Dimension value) =>
      _values[row.index][col.index] = value;

  /// returns the pattern representing this intersection matrix
  String get pattern =>
      _values.map((row) => row.map((col) => col.symbol).join()).join();

  String toString() => pattern;

  bool _matches(List<List<Dimension>> pattern) {
    for (int i=0; i< 3; i++) {
      for (int j=0; j< 3; j++) {
        if (!_values[i][j].matches(pattern[i][j])) return false;
      }
    }
    return true;
  }

  bool get representsEqual => _matches(_EQUAL_PATTERN);
}
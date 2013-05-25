/**
 * This library provides an implementation of the
 * [Bentley-Ottman-Algorithm](http://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm)
 * for computing all intersections of a set of line segments.
 *
 */
library line_intersection;

import "dart:collection";
import "simple_features.dart" show DirectPosition2D;
export "simple_features.dart" show DirectPosition2D;
import "dart:math" as math;
import "package:avl_tree/avl_tree.dart";
import "package:log4dart/log4dart.dart";

part "src/line_intersection.dart";
part "src/util.dart";


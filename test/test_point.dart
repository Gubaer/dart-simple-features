library test_point;

import "dart:async";
import "dart:collection";
import "package:unittest/unittest.dart";
import "package:meta/meta.dart";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";


main() {
  group("boundary -", () {
    test("the boundary of an empty point is empty", () {
      var p = new Point.empty();
      expect(p.boundary.isEmpty, true);
    });

    test("the boundary of any point is empty", () {
      var p = new Point(1,2);
      expect(p.boundary.isEmpty, true);
    });
  });
}

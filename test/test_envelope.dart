library test_envelope;

import "package:unittest/unittest.dart";

part "../lib/src/envelope.dart";
part "../lib/src/geometry.dart";
part "../lib/src/util.dart";
part "../lib/src/point.dart";

main() {
  group("constructors - ", () {
    test("default", () {
      var e = new _Envelope(0,1,2,3);
      expect(e.minx, 0);
      expect(e.miny, 1);
      expect(e.maxx, 2);
      expect(e.maxy, 3);
    });
    test("empty", () {
      var e = new _Envelope.empty();
      expect(e.minx, null);
      expect(e.miny, null);
      expect(e.maxx, null);
      expect(e.maxy, null);
    });
    test("collapsed", (){
        var e = new _Envelope.collapsed(1,2);
        expect(e.minx, 1);
        expect(e.miny, 2);
        expect(e.maxx, 1);
        expect(e.maxy, 2);
    });
  });

  group("converting to geometry -", () {
      test("of an empty envelop", () {
        var e = new _Envelope.empty();
        var g = e.toGeometry();
        expect(g.isEmpty, true);
      });
      test("of a collapsed envelope", () {
        var e = new _Envelope.collapsed(1,2);
        var g = e.toGeometry();
        expect(g is Point, true);
        expect(g.x, 1);
        expect(g.y, 2);
      });
  });
}


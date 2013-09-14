library test_line_intersections_from_data;

import "package:unittest/unittest.dart";
import "package:xml/xml.dart";
import "dart:io";
import "../lib/line_intersection.dart";
part "../lib/src/util.dart";

svg(filename) {
  filename = "test/data/${filename}";
  var content = new File(filename).readAsStringSync();
  var tree =  XML.parse(content);
  return tree;
}

linesegments(svg) {
  var ret = new Map<LineSegment, String>();
  svg.queryAll("line").forEach((s) {
    var x1 = double.parse(s.attributes["x1"]);
    var y1 = double.parse(s.attributes["y1"]);
    var x2 = double.parse(s.attributes["x2"]);
    var y2 = double.parse(s.attributes["y2"]);
    var id = s.attributes["id"];
    ret[new LineSegment.from([x1,y1], [x2,y2])] = id;
  });
  return ret;
}

lookupIntersections(svg) {
    var ret = new Map<DirectPosition2D, List<String>>();
    svg.queryAll("sf:intersection").forEach((i) {
       var references = i.queryAll("sf:segment").map((s) => s.attributes["ref"]).toList();
       var x = double.parse(i.attributes["x"]);
       var y = double.parse(i.attributes["y"]);
       ret[new DirectPosition2D(x,y)] = references;
    });
    return ret;
}

main(){
  runTest(filename) {
    var markup = svg(filename);
    var linesMap = linesegments(markup);
    var expectedIntersectionsMap = lookupIntersections(markup);
    var intersections = computeLineIntersections(linesMap.keys);
    hasIntersectionAt(pos) => expectedIntersectionsMap.containsKey(pos);

    intersections.forEach((inter) {
      expect(hasIntersectionAt(inter.pos), true);
      var ids = inter.intersecting.map((s) => linesMap[s]).toList();
      ids.sort();
      var expectedIds = expectedIntersectionsMap[inter.pos].toList();
      expectedIds.sort();
      expect(ids, equals(expectedIds));
    });
  }

  testScene(file) => test(file, () => runTest(file));

  testScene("scene-01.svg");
  testScene("scene-02.svg");
  testScene("scene-03.svg");
  testScene("scene-04.svg");
  testScene("scene-05.svg");
  testScene("scene-06.svg");
}



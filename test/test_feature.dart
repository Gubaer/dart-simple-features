library test_feature;

import "dart:collection";
import "package:unittest/unittest.dart" hide isEmpty;
import "package:meta/meta.dart";
import "dart:convert";

part "../lib/src/util.dart";
part "../lib/src/point.dart";
part "../lib/src/geometry.dart";
part "../lib/src/geometry_collection.dart";
part "../lib/src/linestring.dart";
part "../lib/src/multilinestring.dart";
part "../lib/src/multipoint.dart";
part "../lib/src/wkt.dart";
part "../lib/src/direct_position.dart";
part "../lib/src/geojson.dart";
part "../lib/src/feature.dart";

main() {
  group("Feature -", () {
    group("constructors", () {
      test("standard - accepts a geomtry and properties", () {
        var geometry = new Point(1,2);
        var properties = {"k1": "v1", "k2":122};
        var feature = new Feature(geometry, properties);
        expect(feature.geometry.x, 1);
        expect(feature.properties["k1"], "v1");
        expect(feature.properties.length, 2);
      });

      test("accepts a geometry only", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry);
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });

      test("accepts a geomtry and null properties", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry, null);
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });

      test("accepts a geomtry and empty properties", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry, {});
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });
    });

    group("json parsing", () {
      test("simple point featue", () {
        var json = """
        {"type": "Feature",
            "geometry":  {"type": "Point", "coordinates": [1,2]},
            "properties": {
               "k1": "string value",
               "k2": 123
            }
        }
        """;
        var feature = parseGeoJson(json);
        expect(feature.geometry.y, 2);
        expect(feature.properties.length, 2);
        expect(feature.properties["k2"], 123);
      });
    });
  });


  group("FeatureCollection -", () {
    group("constructors", () {
      test("standard without parameters", () {
        var fc = new FeatureCollection();
        expect(fc.isEmpty, true);
      });
      test("standard with null features", () {
        var fc = new FeatureCollection(null);
        expect(fc.isEmpty, true);
      });
      test("standard with empty features", () {
        var fc = new FeatureCollection([]);
        expect(fc.isEmpty, true);
      });

      test("with two features", () {
        var f1 = new Feature(new Point(1,2));
        var f2 = new Feature(new Point(3,4), {"k1":"v1"});
        var fc = new FeatureCollection([f1,f2]);
        expect(fc.isEmpty, false);
        expect(fc.length, 2);
        expect(fc.first.geometry.x, 1);
        expect(fc.last.geometry.y, 4);
      });


      test("accepts a geometry only", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry);
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });

      test("accepts a geomtry and null properties", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry, null);
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });

      test("accepts a geomtry and empty properties", () {
        var geometry = new Point(1,2);
        var feature = new Feature(geometry, {});
        expect(feature.geometry.x, 1);
        expect(feature.properties.isEmpty, true);
      });
    });

    group("json parsing", () {
      test("a feature collection with two features", () {
        var json = """
            {"type": "FeatureCollection",
            "features": [
            {"type": "Feature",
            "geometry":  {"type": "Point", "coordinates": [1,2]},
            "properties": {
            "k1": "string value",
            "k2": 123
            }
            },
            {"type": "Feature",
            "geometry":  {"type": "MultiPoint", "coordinates": [[1,2], [3,4], [5,6]]}
            }
            ]
            }
            """;
        var fc = parseGeoJson(json);
        expect(fc is FeatureCollection, true);
        expect(fc.length, 2);
      });
    });
  });
}
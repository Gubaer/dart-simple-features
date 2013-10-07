part of simple_features;

/**
 * Parses GeoJSON.
 *
 * Returns a [Geometry], a [Feature], or a [FeatureCollection].
 *
 */
//TODO: more checks, throw FormatException on error
//TODO: provide an optional factory object, in particular for Features
//  and FeatureCollection
parseGeoJson(String geoJson) {
  var value = JSON.decode(geoJson);
  assert(value is Map);

  Point pos(coord) => new Point(coord[0], coord[1]);
  List<DirectPosition2D> poslist(l) => l.map(pos).toList();

  deserializePoint(Map gj) =>
      pos(gj["coordinates"]);

  deserializeMultiPoint(Map gj) =>
      new MultiPoint(poslist(gj["coordinates"]));

  deserializeLineString(Map gj) =>
      new LineString(poslist(gj["coordinates"]));

  deserializeMultiLineString(Map gj) =>
    new MultiLineString(
      gj["coordinates"]
      .map((ls) => new LineString(poslist(ls)))
      .toList()
    );

  polygonFromCoordinates(coords) {
    var rings = coords
      .map((l) => poslist(l))
      .map((poslist) => new LineString(poslist))
      .toList();
    return new Polygon(rings.first, rings.skip(1));
  }

  deserializePolygon(Map gj) =>
    polygonFromCoordinates(gj["coordinates"]);

  deserializeMultipolygon(Map gj) =>
      new MultiPolygon(
          gj["coordinates"]
          .map((coords) => polygonFromCoordinates(coords))
          .toList()
      );

  var deserialize;

  deserializeGeometryCollection(Map gj) =>
      new GeometryCollection(gj["geometries"]
        .map((o) => deserialize(o))
        .toList()
      );

  deserializeFeature(Map gj) {
    var geometry = deserialize(gj["geometry"]);
    var properties = gj["properties"];
    return new Feature(geometry, properties);
  }

  deserializeFeatureCollection(Map gj) {
    var features = gj["features"]
      .map((f) => deserializeFeature(f))
      .toList();
    return new FeatureCollection(features);
  }

  deserialize = (Map gj) {
    switch(gj["type"]) {
      case "Point":      return deserializePoint(gj);
      case "MultiPoint": return deserializeMultiPoint(gj);
      case "LineString": return deserializeLineString(gj);
      case "MultiLineString": return deserializeMultiLineString(gj);
      case "Polygon":    return deserializePolygon(gj);
      case "MultiPolygon": return deserializeMultipolygon(gj);
      case "GeometryCollection": return deserializeGeometryCollection(gj);
      case "Feature": return deserializeFeature(gj);
      case "FeatureCollection" : return deserializeFeatureCollection(gj);
      default:
        throw new FormatException(
            "unknown GeoJson object type '${gj['type']}"
        );
    }
  };

  return deserialize(value);
}

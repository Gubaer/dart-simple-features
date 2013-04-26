import "test_envelope.dart" as test_envelope;
import "test_point.dart" as test_point;
import "test_multipoint.dart" as test_multipoint;
import "test_linestring.dart" as test_linestring;
import "test_polygon.dart" as test_polygon;
import "test_multipolygon.dart" as test_multipolygon;
import "test_polyhedral_surface.dart" as test_polyhedral_surface;
import "test_wkt.dart" as test_wkt;
import "test_geometry_collection.dart" as test_geometry_collection;

main() {
  test_envelope.main();
  test_point.main();
  test_multipoint.main();
  test_linestring.main();
  test_polygon.main();
  test_multipolygon.main();
  test_wkt.main();
  test_polyhedral_surface.main();
  test_geometry_collection.main();
}


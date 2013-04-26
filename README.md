`simple_features` is a [Dart](http://www.dartlang.org) implementation of 
[OGC](http://www.opengeospatial.org/)s 
[Simple Feature Specification](http://www.opengeospatial.org/standards/sfa) (SFS).

The SFS defines a hierarchy of geometry types which are used in 
geographical information systems. Most database systems mit spatial
functionality as well as software frameworks for processing GIS data provide
an implementation of the SFS. 

## API documentation
See [output from dartdoc](http://gubaer.github.io/dart-simple-features/doc/index.html)

## Status
This is work in progress. 

As of the current version 0.0.1:

* The geometry type hierarchy is implemented in a matching class hierarchy
* Geometries can be read from an serialized into Well-Known Text Representation
  (WKT). Support for GeoJSON is provided too. 
* Basic properties of a Geometry like `dimension`, `geometryType`, `isMeasured`,
  or `is3D` are implemented.
* Some more complicated properties like `isSimple` or `bounary` are so far
  implemented on a subset of the geometry types only.
* The [Dimensionally Extended nine-Intesection Model](http://en.wikipedia.org/wiki/DE-9IM)
  (DE-9IM) isn't implemented yet. It isn't possible yet to relate one geometry
  to another, for instance in order to test, whether one geometry *crosses* or
  *overlaps* the other.  


## License 
`simple_features` is license under the Apache 2.0 license, see files LICENSE and NOTICE.

	
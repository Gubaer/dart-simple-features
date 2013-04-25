part of simple_features;

/**
 * Used to annotate methods or properties in this SFS implementation with the
 * original method name from the SFS.
 */
const specification = const _Specification();

class _Specification {
  final String name;
  const _Specification([this.name=null]);
}
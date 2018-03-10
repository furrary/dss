/// An interface for a unique class name generator.
typedef String NameGenerator();

/// The default [NameGenerator].
///
/// Generates a name starting with `dss-`, followed by a number
/// which will increase by `1` each time this is called.
String generateIncrementalName() => 'dss-${_counter++}';

int _counter = 0;

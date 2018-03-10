/// This library lets you change the way CSS rule is inserted into the DOM
/// and change how unique class names are generated.
///
/// The config needs to be done before any function in this package is called.
///
/// ```dart
/// import 'config.dart' as config;
///
/// String generateAwesomeName() => 'awesome';
///
/// void main() {
///   config.generateUniqueName = generateAwesomeName;
/// }
/// ```
library config;

export 'src/config.dart';
export 'src/name_generator.dart';
export 'src/style_sheet.dart';

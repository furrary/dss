/// This library lets you change the way CSS rule is inserted into the DOM and change how unique class names are generated.
///
/// ```dart
/// import 'package:dss/config.dart';
///
/// class AwesomeNameGenerator extends NameGenerator {
///   @override
///   String generate() => 'awesome';
/// }
///
/// void main() {
///   Config.nameGenerator = new AwesomeNameGenerator();
/// }
/// ```
library config;

export 'src/config.dart';

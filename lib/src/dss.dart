import 'config.dart';
import 'parser.dart';

/// Inserts a CSS rule with the given selector and declarations markup.
///
/// ```dart
/// void main() {
///   global(
///     'html, body',
///     'padding: 0;',
///   );
/// }
/// ```
/// This is just the same as the following code in `.css` file.
/// ```css
/// html, body {
///   padding: 0;
/// }
/// ```
void global(String selector, String markup) {
  parseAndInsert(selector, markup);
}

/// Inserts a CSS rule with the given declarations markup and
/// returns a generated unique name to use as `className`.
///
/// If [isDev] is `true`, [prefix] will be added before the generated class name for the sake of debugging.
///
/// The examples show how you would use this function.
/// ```dart
/// querySelector('someSelector')
///   ..className = dss(
///       'color: red;'
///       'font-size: 100px;',
///       prefix: 'big-red-')
///   ..text = "Hello";
/// ```
///
/// ```dart
/// final forIpad = '@media (min-width: 768px) and (max-width: 1024px)';
/// final box = dss('''
///   color: red;
///
///   $forIpad {
///     color: blue;
///   }
/// ''');
///
/// void main() {
///   querySelector('someSelector')
///     ..className = box
///     ..text = 'I\'m normally red, but turn blue on an iPad.';
/// }
/// ```
String dss(String markup, {String prefix}) {
  String name = generateUniqueName();
  if (isDev && prefix != null) {
    name = prefix + name;
  }
  parseAndInsert('.$name', markup);
  return name;
}

/// CSS's @import.
///
/// ```dart
/// importCss("url('https://fonts.googleapis.com/css?family=Roboto')", 'screen');
/// ```
void importCss(String url, [String mediaQuery = '']) {
  if (!url.startsWith(url) && !url.startsWith('"') && !url.startsWith("'")) {
    url = '"$url"';
  }
  sheet.addFirst('@import $url $mediaQuery;');
}

/// Inserts a `@keyframes` rule and returns a unique name for the animation.
///
/// If [isDev] is `true`, [prefix] will be added before the generated animation name for the sake of debugging.
///
/// ```dart
/// final fontBulger = keyframes('''
///   0%, 100% {
///     font-size: 10px;
///   }
///   50% {
///     font-size: 15px;
///   }
/// ''');
///
/// querySelector('someSelector')
///   ..className = dss('animation: $fontBulger 2s infinite')
///   ..text = "Hello";
/// ```
String keyframes(String markup, {String prefix}) {
  String name = generateUniqueName();
  if (isDev && prefix != null) {
    name = prefix + name;
  }
  sheet.add('@keyframes $name{$markup}');
  return name;
}

/// Inserts a `@font-face` rule.
///
/// ```dart
/// fontFace('''
///   font-family: "Open Sans";
///   src: url("/fonts/OpenSans-Regular-webfont.woff2") format("woff2"),
///        url("/fonts/OpenSans-Regular-webfont.woff") format("woff");
/// ''');
/// ```
void fontFace(String markup) {
  sheet.add('@font-face {$markup}');
}

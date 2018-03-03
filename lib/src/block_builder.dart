import 'parser.dart';

/// A mixin for building CSS declarations block.
abstract class BlockBuilder {
  /// An abstraction over a CSS declarations block.
  ///
  /// This is a low level API. You might not need to access this.
  ///
  /// I opt to use `List` instead of `Map` because, as you can see in the example,
  /// you may need to write some fallbacks which is hard to implement with Dart's non-multi map.
  ///
  /// ```dart
  /// [
  ///   'color: rgb(255 0 0 / 0.8)',
  ///   'color: red',
  ///   'font-size: 10px',
  /// ]
  /// ```
  /// Is the same as:
  /// ```css
  /// {
  ///   color: rgb(255 0 0 / 0.8);
  ///   color: red;
  ///   font-size: 10px;
  /// }
  /// ```
  List<String> get declarations;

  /// Adds a CSS declaration.
  ///
  /// A [CSS declaration][] consists of a property and its respective value.
  ///
  /// [CSS declaration]: https://developer.mozilla.org/en-US/docs/Web/CSS/Syntax#CSS_declarations_blocks
  void add(String property, String value) {
    declarations.add('$property:$value');
  }

  /// Adds a map of CSS declarations.
  ///
  /// If you want to add many CSS declarations at once, this may be more declarative than the simpler [add].
  ///
  /// IMO, sorting the fallback values starting from the most preferable one is more declarative.
  /// If you think this is confusing and should be otherwise, please file an issue.
  ///
  /// ```dart
  /// final bigPurple = {
  ///   'font-size': '200px',
  ///   'color': 'rebeccapurple',
  /// };
  /// final purpleFallbacks = {
  ///   'color': ['violet', 'purple'],
  /// };
  /// new Dss()
  ///   ..select('.title')
  ///   ..addMap(bigPurple, fallback: purpleFallbacks)
  ///   ..register();
  /// ```
  /// Is equivalent to:
  /// ```dart
  /// new Dss()
  ///   ..select('.title')
  ///   ..add('color', 'purple')
  ///   ..add('color', 'violet')
  ///   ..add('font-size', '200px')
  ///   ..add('color', 'rebeccapurple')
  ///   ..register();
  /// ```
  void addMap(Map<String, String> declarations,
      {Map<String, List<String>> fallback}) {
    if (fallback != null) {
      this.declarations.addAll(fallbackToIterable(fallback));
    }
    this.declarations.addAll(mapToIterable(declarations));
  }

  /// Composes only the declarations block.
  ///
  /// ```dart
  /// final redButBlueOnBigScreen = new Dss.map({'color': 'red'})
  ///   ..media(Media()
  ///     ..screen()
  ///     ..minWidth('600px')
  ///     ..add('color', 'blue'));
  /// final bigButSmallOnBigScreen = new Dss.map({'font-size': '100px'})
  ///   ..media(Media()
  ///     ..screen()
  ///     ..minWidth('600px')
  ///     ..add('font-size', '20px'));
  /// final bigRed = Dss()
  ///   ..shallowCompose(bigButSmallOnBigScreen)
  ///   ..shallowCompose(redButBlueOnBigScreen);
  /// ```
  /// `bigRed` is equivalent to:
  /// ```css
  /// .bigRed {
  ///   font-size: 100px;
  ///   color: red;
  ///   /* without media queries */
  /// }
  /// ```
  void shallowCompose(BlockBuilder other) {
    declarations.addAll(other.declarations);
  }
}

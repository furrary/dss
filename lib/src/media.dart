import 'block_builder.dart';

/// A media rule builder.
///
/// ```dart
/// Media notForIpad() => Media()
///   ..not()
///   ..screen()
///   ..minWidth('768px')
///   ..maxWidth('1024px');
///
/// final box = new Dss()
///   ..add('color', 'red')
///   ..media(notForIpad()
///     ..add('color', 'blue'));
/// ```
///
/// The `box` will be `red` on an iPad, and `blue` on other media.
class Media extends Object with BlockBuilder {
  @override
  final List<String> declarations = [];

  /// Gets the query
  String get query {
    if (_query.startsWith('and')) {
      _query = _query.substring(3);
    }
    return _query;
  }

  /// Specifies the query of this media rule.
  void inquire(String query) {
    _query = query;
  }

  /// A syntactic sugar for `this.inquire(this.query + 'not ')`.
  ///
  /// Please note that after `not`, you need to spicify a [media type][].
  ///
  /// [media type][]: https://developer.mozilla.org/en-US/docs/Web/CSS/@media#Media_types
  void not() {
    _query += 'not ';
  }

  /// A syntactic sugar for `this.inquire(this.query + 'all ')`.
  void all() {
    _query += 'all ';
  }

  /// A syntactic sugar for `this.inquire(this.query + 'screen ')`.
  void screen() {
    _query += 'screen ';
  }

  /// A syntactic sugar for `this.inquire(this.query + 'print ')`.
  void print() {
    _query += 'print ';
  }

  /// A syntactic sugar for `this.inquire(this.query + 'speech ')`.
  void speech() {
    _query += 'speech ';
  }

  /// A syntactic sugar for `this.inquire(this.query + ', ' + other.query)`.
  void or(Media other) {
    _query += ', ' + other.query;
  }

  /// A syntactic sugar for `this.inquire(this.query + ', ' + otherQuery)`.
  void orQuery(String otherQuery) {
    _query += ', ' + otherQuery;
  }

  /// Adds a [media feature][].
  ///
  /// [media feature]: https://developer.mozilla.org/en-US/docs/Web/CSS/@media#Media_features
  void feat(String feature) {
    _query += 'and (' + feature + ')';
  }

  void width(String width) {
    feat('width:$width');
  }

  void minWidth(String width) {
    feat('min-width:$width');
  }

  void maxWidth(String width) {
    feat('max-width:$width');
  }

  void height(String height) {
    feat('height:$height');
  }

  void minHeight(String height) {
    feat('min-height:$height');
  }

  void maxHeight(String height) {
    feat('max-height:$height');
  }

  void portrait() {
    feat('orientation:portrait');
  }

  void landscape() {
    feat('orientation:landscape');
  }

  String _query = '';
}

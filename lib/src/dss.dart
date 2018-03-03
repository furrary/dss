import 'block_builder.dart';
import 'config.dart';
import 'media.dart';
import 'parser.dart';

/// An abstraction over a CSS rule.
///
/// This utilizes the builder pattern, so when you finish building your rule, you need to call [register] to make this rule usable.
///
/// You can specify this rule selector by calling [select].
/// If you don't specify the selector, it will be auto-generated as a class selector.
/// You may access the generated uniqe class name via the getter [name].
/// Additionally, [name] will conveniently call [register] for you.
///
/// Please note that [register] can be called only once. Call it only when you finish building your rule.
///
/// Here's how to apply the rule.
/// ```dart
/// querySelector('someSelector').className = (new Dss()
///       ..add('color', 'red')
///       ..add('font-size', '12px'))
///     .name;
/// ```
/// For a global rule:
/// ```dart
/// new Dss()
///   ..select('html, body')
///   ..add('padding', '0')
///   ..register();
/// ```
class Dss extends Object with BlockBuilder {
  /// A normal CSS selector.
  String get selector => _selector ?? '.$_name';

  @override
  final List<String> declarations = [];

  /// An abstraction over CSS `@media` rules.
  ///
  /// This is a low level API. You might not need to access this.
  ///
  /// _This field can be `null`._
  ///
  /// ```dart
  /// new Dss()
  ///   ..select('p')
  ///   ..add('font-size', '20px')
  ///   ..mediaQueries = {
  ///     '(max-width: 512px)': [
  ///       'font-size: 10px',
  ///     ]
  ///   }
  ///   ..register();
  /// ```
  ///
  /// Compiles to:
  ///
  /// ```css
  /// p {
  ///   font-size: 20px;
  /// }
  ///
  /// @media (max-width: 512px) {
  ///   p {
  ///     font-size: 10px;
  ///   }
  /// }
  /// ```
  Map<String, List<String>> mediaRules;

  /// Gets a unique class name of this rule.
  ///
  /// This also calls [register], so you don't need to call it yourself.
  /// If you have already specified the [selector] via [select], this is pretty useless.
  String get name {
    register();
    return _name;
  }

  Dss() : _name = Config.nameGenerator.generate();

  /// A syntactic sugar for `new Dss()..addMap`
  factory Dss.map(Map<String, String> declarations,
          {Map<String, List<String>> fallback}) =>
      new Dss()..addMap(declarations, fallback: fallback);

  /// Adds a prefix to the [name] of this rule.
  ///
  /// This is only useful for debugging.
  void debug(String prefix) {
    _name = prefix + _name;
  }

  /// Specifies this rule selector.
  ///
  /// This is useful for making a global CSS rule or a nested rule.
  /// Otherwise, using the unique class [name] is vastly superior.
  void select(String selector) {
    _selector = selector;
  }

  /// Adds a media rule.
  ///
  /// ```dart
  /// final box = new Dss()
  ///   ..add('color', 'red')
  ///   ..media(Media()
  ///     ..inquire('(min-width: 768px) and (max-width: 1024px)')
  ///     ..add('color', 'blue'));
  /// ```
  ///
  /// Compiles to
  ///
  /// ```css
  /// .box {
  ///   color: red;
  /// }
  ///
  /// @media (min-width: 768px) and (max-width: 1024px) {
  ///   .box {
  ///     color: blue;
  ///   }
  /// }
  /// ```
  void media(Media mediaRule) {
    mediaRules ??= {};
    mediaRules[mediaRule.query] = new List.from(mediaRule.declarations);
  }

  /// Adds a child rule.
  ///
  /// This concept does not exist in CSS, but is extremely common in SCSS and other CSS preprocessors.
  ///
  /// The child selector can access the parent's selector via the special character `&`.
  /// This makes it super easy to add pseudoclasses and more.
  ///
  /// Example:
  /// ```dart
  /// final box = new Dss()
  ///   ..add('color', 'red')
  ///   ..nest(Dss()
  ///     ..select('&:hover')
  ///     ..add('color', 'blue'))
  ///   ..nest(Dss()
  ///     ..select('> h5')
  ///     ..add('font-size', '20px')
  ///     ..nest(Dss()
  ///       ..select('.bigger > &')
  ///       ..add('font-size', '30px')));
  /// ```
  ///
  /// Compiles to
  ///
  /// ```css
  /// .box {
  ///   color: red;
  /// }
  ///
  /// .box:hover {
  ///   color: blue;
  /// }
  ///
  /// .box > h5 {
  ///   font-size: 20px;
  /// }
  ///
  /// .bigger > .box > h5 {
  ///   font-size: 30px;
  /// }
  /// ```
  void nest(Dss child) {
    final childSelector = child.selector;
    if (!childSelector.contains('&')) {
      child.select('& ' + childSelector);
    }
    _children ??= [];
    _children.add(child);
  }

  /// Composes this rule with another rule.
  ///
  /// This example shows how the composability enables you to declaratively write a powerful rule.
  ///
  /// ```dart
  /// final bigOnMobile = new Dss()
  ///   ..add('font-size', '20px')
  ///   ..media(Media()
  ///     ..screen()
  ///     ..maxWidth('650px')
  ///     ..add('font-size', '30px'));
  ///
  /// final redWhenHovered = new Dss()
  ///   ..nest(Dss()
  ///     ..select('&:hover')
  ///     ..add('color', 'red'));
  ///
  /// final blue = new Dss()
  ///   ..add('color', 'blue')
  ///   ..compose(redWhenHovered);
  ///
  /// final green = new Dss()
  ///   ..add('color', 'green')
  ///   ..compose(redWhenHovered)
  ///   ..compose(bigOnMobile);
  /// ```
  void compose(Dss other) {
    declarations.addAll(other.declarations);
    if (other.mediaRules != null) {
      mediaRules ??= {};
      other.mediaRules.forEach((query, declarations) {
        mediaRules[query] ??= [];
        mediaRules[query].addAll(declarations);
      });
    }
    if (other._children != null) {
      _children ??= [];
      _children.addAll(other._children);
    }
  }

  /// Registers a rule so that it is usable.
  ///
  /// Only call this method when you finish building your rule with [select], [add], [media], etc.
  void register() {
    if (!_isRegistered) {
      final flatRules = flattenedRules();
      for (var i = 0, l = flatRules.length; i < l; i++) {
        _parseAndAddFlatRule(flatRules[i]);
      }
      // TODO: Check if this helps with memory optimization.
      // declarations.clear();
      // mediaRules?.clear();
      // _children?.clear();
      _isRegistered = true;
    }
  }

  /// Flattened nested rules.
  ///
  /// This is only used by parsers. You may not need to access this.
  List<Dss> flattenedRules() {
    final flatRules = [this];
    if (_children != null) {
      for (var i = 0, l = _children.length; i < l; i++) {
        _children[i].select(_children[i].selector.replaceAll('&', selector));
        flatRules.addAll(_children[i].flattenedRules());
      }
    }
    return flatRules;
  }

  bool _isRegistered = false;
  List<Dss> _children;
  String _name;
  String _selector;
}

void _parseAndAddFlatRule(Dss rule) {
  Config.sheet.add(parseSimpleRule(rule.selector, rule.declarations));
  if (rule.mediaRules != null) {
    parseMediaRules(rule.selector, rule.mediaRules).forEach(Config.sheet.add);
  }
}

import 'dart:html';

class Config {
  /// The [AbstractStyleSheet] which will be used across the library.
  ///
  /// This defaults to a [BrowserStyleSheet].
  static AbstractStyleSheet sheet = new BrowserStyleSheet();

  /// A unique class name generator which will be used across the library.
  ///
  /// This defaults to an [IncrementalNameGenerator].
  static NameGenerator nameGenerator = new IncrementalNameGenerator();
}

/// An interface for managing CSS rules.
///
/// You can implement your own [AbstractStyleSheet], if the default one doesn't suit your use cases or is simply incompetent.
abstract class AbstractStyleSheet {
  /// Appends a CSS rule at the end of this stylesheet.
  void add(String rule);

  /// Inserts a CSS rule at the beginning of this stylesheet.
  void addFirst(String rule);
}

/// An interface for a unique name generator used by `Dss`.
///
/// You can implement your own [NameGenerator], if the default one doesn't suit your use cases or is simply incompetent.
abstract class NameGenerator {
  /// Generates a unique name.
  String generate();
}

/// The default [NameGenerator].
///
/// This generator [generate]s a name starting with `dss-`, followed by a number
/// which will increase by `1` each time [generate] is called.
class IncrementalNameGenerator extends NameGenerator {
  static int _counter = 0;

  @override
  String generate() => 'dss-${_counter++}';
}

/// A stylesheet which will insert rules into a `<style>` tag.
///
/// This utilizes the [`CSSStyleSheet.insertRule`][].
///
/// [`CSSStyleSheet.insertRule`]: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleSheet/insertRule
class BrowserStyleSheet extends AbstractStyleSheet {
  BrowserStyleSheet() {
    document.head.append(_styleEl);
    _sheet = _styleEl.sheet as CssStyleSheet;
  }

  @override
  void add(String rule) {
    _sheet.insertRule(rule, _ruleCounter);
    _ruleCounter++;
  }

  @override
  void addFirst(String rule) {
    _sheet.insertRule(rule, 0);
    _ruleCounter++;
  }

  final _styleEl = new StyleElement()
    ..type = 'text/css'
    ..setAttribute('data-dss', '')
    // WebKit hack
    ..appendText('');

  CssStyleSheet _sheet;
  var _ruleCounter = 0;
}

/// A stylesheet which will concatenate rules into a string that can be used for server-side rendering.
///
/// Since, right now, there is no Dart web framework that is capable of server-side rendering,
/// this is useless.
class StringStyleSheet extends AbstractStyleSheet {
  String _sheet = '';

  String get sheet => _sheet;

  @override
  void add(String rule) {
    _sheet += rule;
  }

  @override
  void addFirst(String rule) {
    _sheet = rule + _sheet;
  }
}

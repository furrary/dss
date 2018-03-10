import 'dart:html';

import 'config.dart';

/// An interface for managing CSS rules.
///
/// You can implement your own [AbstractStyleSheet], if the default one doesn't suit your use cases or is simply incompetent.
abstract class AbstractStyleSheet {
  /// Appends a CSS rule at the end of this stylesheet.
  void add(String rule);

  /// Inserts a CSS rule at the beginning of this stylesheet.
  ///
  /// This is useful for `@import` rules.
  void addFirst(String rule);
}

/// A stylesheet which will insert rules into a `<style>` tag.
///
/// This is a low-level API and only accepts a valid CSS rule, so nested rules won't be accpeted.
///
/// This utilizes the [`CSSStyleSheet.insertRule`][] in production mode.
///
/// [`CSSStyleSheet.insertRule`]: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleSheet/insertRule
class BrowserStyleSheet extends AbstractStyleSheet {
  BrowserStyleSheet() {
    document.head.append(_styleEl);
    _sheet = _styleEl.sheet as CssStyleSheet;
  }

  @override
  void add(String rule) {
    if (!isDev) {
      _sheet.insertRule(rule, _ruleCounter);
    } else {
      _styleEl.appendText(rule);
    }
    _ruleCounter++;
  }

  @override
  void addFirst(String rule) {
    if (!isDev) {
      _sheet.insertRule(rule, 0);
    } else {
      _styleEl.insertBefore(new Text(rule), _styleEl.firstChild);
    }
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
class ServerStyleSheet extends AbstractStyleSheet {
  // TODO: Implement this class

  @override
  void add(String rule) {
    _unimplemented();
  }

  @override
  void addFirst(String rule) {
    _unimplemented();
  }

  void _unimplemented() {
    throw new UnimplementedError(
        "There is no Dart web framework that is capable of server-side rendering, thus this is useless, for now.");
  }
}

import 'config.dart';

const semicolon = 59; // ;
const openBrace = 123; // {
const closeBrace = 125; // }
const atRule = 64; // @
const maxDepth = 6;

final selectors = new List<String>.filled(maxDepth, '');
final rules = <String, String>{};

void parseAndInsert(String selector, String markup) {
  markup = markup.trim();
  selectors[0] = selector;

  int index = 0;
  int markupLength = markup.length;
  int depth = 0;
  int lastSemicolon = -1;
  int lastCloseBrace = -1;
  int lastOpenBrace = -1;

  while (index < markupLength) {
    int code = markup.codeUnitAt(index);
    if (code == semicolon) {
      lastSemicolon = index;
    } else if (code == openBrace || code == closeBrace) {
      final start = lastOpenBrace > lastCloseBrace
          ? lastOpenBrace + 1
          : lastCloseBrace + 1;
      final end = lastSemicolon > lastCloseBrace
          ? lastSemicolon + 1
          : lastCloseBrace + 1;

      if (!rules.containsKey(selectors[depth])) {
        rules[selectors[depth]] = markup.substring(start, end);
      } else {
        rules[selectors[depth]] += markup.substring(start, end);
      }

      if (code == openBrace) {
        if (isDev && selectors[depth].codeUnitAt(0) == atRule) {
          throw new UnsupportedError("An @media rule can't have a child.");
        }

        depth++;

        if (isDev && depth >= maxDepth) {
          throw new UnsupportedError(
              "Too deeply nested. Going deeper than $maxDepth levels is not allowed.");
        }

        final rawSelector = markup.substring(end, index).trim();
        selectors[depth] = rawSelector.codeUnitAt(0) == atRule
            ? '$rawSelector{${selectors[depth - 1]}'
            : rawSelector.contains('&')
                ? rawSelector.replaceAll('&', selectors[depth - 1])
                : '${selectors[depth - 1]} $rawSelector';
        lastOpenBrace = index;
      } else {
        depth--;
        lastCloseBrace = index;
      }
    }
    index++;
  }

  // A rule without children.
  if (lastOpenBrace == -1) {
    rules[selector] = markup;
  }

  rules.forEach((selector, declarations) {
    if (selector.codeUnitAt(0) == atRule) {
      sheet.add('$selector{$declarations}}');
    } else {
      sheet.add('$selector{$declarations}');
    }
  });

  rules.clear();
}

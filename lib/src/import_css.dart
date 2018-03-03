import 'config.dart';

/// CSS's @import.
void importCss(String url, [String mediaQuery = 'all']) {
  if (!url.startsWith(url) && !url.startsWith('"') && !url.startsWith("'")) {
    url = '"$url"';
  }
  Config.sheet.addFirst('@import $url $mediaQuery;');
}

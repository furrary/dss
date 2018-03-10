# DSS: CSS in Dart

DSS stands for Dart StyleSheet.

In the JavaScript community, there's a growing trend towards CSS in JS.
It has some pros and, certainly, cons, but I won't point that out here because tons of great articles out there have already done that.

To my knowledge, at the time I wrote this, there's no library to do CSS in Dart yet. So, there you go, the first library of its kind.

This library is lightweight and platform agnostic. It doesn't do anything special. It doesn't auto-prefix your rules. It doesn't have some sophisticated cache. It just enables you to write CSS in Dart.

_[dartdocs.org][] uses Dart 1.x SDK to generate docs and fails to build, so I need to build the [docs][] myself._

## Usage

### Regular Rule

CSS

```css
.dss-0 {
  color: red;
  font-size: 12px;
}
```

DSS

```dart
querySelector('someSelector').className = dss(''
    'color: red;'
    'font-size: 12px;');
```

`dss` will generate a unique class name for your rule, parse the rule and insert it into a `<style>` tag.

### Global Rule

You might need to specify the selector yourself.

CSS

```css
html,
body {
  padding: 0;
}
```

DSS

```dart
global(
  'html, body',
  'padding: 0;',
);
```

### Nesting and Pseudoclasses

CSS

```css
.box {
  color: red;
}

.box:hover {
  color: blue;
}

.box > h5 {
  font-size: 20px;
}

.bigger > .box > h5 {
  font-size: 30px;
}
```

DSS

```dart
final box = dss('''
  color: red;

  &:hover {
    color: blue;
  }

  > h5 {
    font-size: 20px;
  }

  .bigger > & > h5 {
    font-size: 30px;
  }
''');
```

`dss` can generate a unique class name for you, so the concept of nesting might not be that important anymore, except for pseudoclasses, markups and legacy CSS interops.

### Fallback Values

CSS

```css
.box {
  color: purple;
  color: rebeccapurple;
}
```

DSS

```dart
// There's nothing special here.
final box = dss(''
    'color: purple;'
    'color: rebeccapurple;');
```

### Media Queries `@media`

CSS

```css
.box {
  color: red;
}

@media (min-width: 768px) and (max-width: 1024px) {
  .box {
    color: blue;
  }
}
```

DSS

```dart
final forIpad = '@media (min-width: 768px) and (max-width: 1024px)';
final box = dss('''
  color: red;

  $forIpad {
    color: blue;
  }
''');
```

### Font Face `@font-face`

CSS

```css
@font-face {
  font-family: "Open Sans";
  src: url("/fonts/OpenSans-Regular-webfont.woff2") format("woff2"), url("/fonts/OpenSans-Regular-webfont.woff")
      format("woff");
}
```

DSS

```dart
fontFace('''
  font-family: "Open Sans";
  src: url("/fonts/OpenSans-Regular-webfont.woff2") format("woff2"),
       url("/fonts/OpenSans-Regular-webfont.woff") format("woff");
''');
```

### Keyframes `@keyframes`

CSS

```css
@keyframes fontbulger {
  0%,
  100% {
    font-size: 10px;
  }
  50% {
    font-size: 12px;
  }
}

.dss-0 {
  animation: fontbulger 2s infinite;
}
```

DSS

```dart
final fontBulger = keyframes('''
  0%,
  100% {
    font-size: 10px;
  }
  50% {
    font-size: 12px;
  }
''');

querySelector('someSelector')
  ..className = dss('animation: $fontBulger 2s infinite;')
  ..text = "Hello";
```

### Import `@import`

CSS

```css
@import url("https://fonts.googleapis.com/css?family=Roboto") screen;
```

DSS

```dart
importCss("url('https://fonts.googleapis.com/css?family=Roboto')", 'screen');
```

### Supports `@supports`

Just use the native [`Css.supports`][] and [`Css.supportsCondition`][].

### Theming

```dart
String themedClass(String primaryColor, String textColor) => dss('''
  color: $textColor;
  background-color: $primaryColor;
''');
```

Moreover, it can be more reusable with cache.

```dart
class Theme {
  String primaryColor;
  String textColor;
  Theme(this.primaryColor, this.textColor);
}

final cache = new Expando<String>();

ButtonElement themedButton(Theme theme, [String text = 'Click!']) {
  if (cache[theme] == null) {
    cache[theme] = dss(''
        'color: ${theme.textColor};'
        'background-color: ${theme.primaryColor};');
  }
  return new ButtonElement()
    ..className = cache[theme]
    ..text = text;
}

void main() {
  final lightTheme = new Theme('white', 'black');
  final darkTheme = new Theme('black', 'white');
  document.body.append(themedButton(lightTheme));
  document.body.append(themedButton(darkTheme));
  document.body.append(
      themedButton(lightTheme, 'Do not click!')..setAttribute('disabled', ''));
}
```

This will result in

```html
<button class="dss-0">Click!</button>
<button class="dss-1">Click!</button>
<button class="dss-0" disabled>Do not click!</button>
```

### Composibility

CSS

```css
.blue {
  color: blue;
}

.blue:hover {
  color: red;
}

.green {
  color: green;
}

.green:hover {
  color: red;
}
```

DSS

```dart
final redOnHoverMixin = '''
  &:hover {
    color: red;
  }
''';

final blue = dss('''
  color: blue;
  $redOnHoverMixin
''');

final green = dss('''
  color: green;
  $redOnHoverMixin
''');
```

### Production Mode

Production mode will utilize the [`CSSStyleSheet.insertRule`][]. `insertRule` is super fast, but its big drawback is that the css won't show in devtool's `<style>`.

To enable production mode, set an environment variable `dss` to `prod`.

An example of what `build.yaml` would look like:

```yaml
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        options:
          compiler: dart2js
          dart2js_args:
          - --fast-startup
          - --minify
          - --trust-type-annotations
          - --trust-primitives
          - -Ddss=prod # This line is needed to enable production mode.
```

[dartdocs.org]: https://www.dartdocs.org/
[docs]: https://furrary.github.io/dss/
[`css.supports`]: https://api.dartlang.org/dev/dart-html/Css/supports.html
[`css.supportscondition`]: https://api.dartlang.org/dev/dart-html/Css/supportsCondition.html
[`cssstylesheet.insertrule`]: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleSheet/insertRule

# DSS: CSS in Dart

DSS stands for Dart StyleSheet.

In the JavaScript community, there's a growing trend towards CSS in JS.
It has some pros and, certainly, cons, but I won't point that out here because tons of great articles out there have already done that.

To my knowledge, at the time I wrote this, there's no library to do CSS in Dart yet. So, there you go, the first library of its kind.

I want this library to utilize as many Dart's benefits as possible. Those include [optional new][], method cascades and `dart2js`'s tree shaking. Thus, I decide not to use [`package:js`][] because, yeah, it won't be darty enough.

The APIs may not be as magical as JS because, since the introduction of strong mode, Dart is not a dynamic language anymore. You inevitably need more boilerplates to accomplish the same thing. If you have an idea of how to improve these APIs, feel free to file an issue or create a better library. If you do create a new library, please tell me. I want to use it as well :)

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
querySelector('someSelector').className = (Dss() // Dart2's optional new
      ..add('color', 'red')
      ..add('font-size', '12px'))
    .name;
```

### Global Rule

CSS

```css
html,
body {
  padding: 0;
}
```

DSS

```dart
Dss()
  ..select('html, body')
  ..add('padding', '0')
  ..register();
```

You need to call `register()`, otherwise the library will never know if you are done with the rule declaration or not, and the rule won't be inserted.

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
final box = new Dss()
  ..add('color', 'red')
  ..nest(Dss()
    ..select('&:hover')
    ..add('color', 'blue'))
  ..nest(Dss()
    ..select('> h5')
    ..add('font-size', '20px')
    ..nest(Dss()
      ..select('.bigger > &')
      ..add('font-size', '30px')));
```

If you don't specify the selector for a `Dss` instance, it will have a unique class name. So, the concept of nesting might not be that important anymore, except for pseudoclasses, markups and legacy CSS interops.

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
final box = new Dss()..add('color','purple')..add('color', 'rebeccapurple');
```

It can be a bit more declarative, but, IMO, needs some unnecessary parsing.

```dart
final box = new Dss()
  ..addMap({
    'color': 'rebeccapurple'
  }, fallback: {
    'color': ['purple']
  });
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
final box = new Dss()
  ..add('color', 'red')
  ..media(Media()
    ..inquire('(min-width: 768px) and (max-width: 1024px)')
    ..add('color', 'blue'));
```

or

```dart
Media forIpad() => Media()
  ..minWidth('768px')
  ..maxWidth('1024px');

final box = new Dss()
  ..add('color', 'red')
  ..media(forIpad()
    ..add('color', 'blue'));
```

Caution: `minWidth` and `maxWidth` implementations are just string concatenations. Do not think it does some magical stuff. You need to understand how to write a correct [media query][] anyway.

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
Dss()
  ..select('@font-face')
  ..add('font-family', 'Open Sans')
  ..add(
      'src',
      'url("/fonts/OpenSans-Regular-webfont.woff2") format("woff2"),'
      'url("/fonts/OpenSans-Regular-webfont.woff") format("woff")')
  ..register();
```

To my knowledge, `@font-face` is just a global rule. If there's anything special about `@font-face` that you can't deal with, please file an issue.

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
final fontBulger = new Keyframes()
  ..add(Frame.list([0, 100])..add('font-size', '10px'))
  ..add(Frame(50)..add('font-size', '12px'));

querySelector('querySelector')
  ..className =
      (Dss()..add('animation', '${fontBulger.name} 2s infinite')).name
```

### Import `@import`

CSS

```css
@import url("https://fonts.googleapis.com/css?family=Roboto") screen;
```

DSS

```dart
importCss("url('https://fonts.googleapis.com/css?family=Roboto')",
    (Media()..screen()).query);
```

### Supports `@supports`

Just use the native [`Css.supports`][] and [`Css.supportsCondition`][].

### Theming

```dart
Dss themedClass(String primaryColor, String textColor) =>
    Dss()..add('color', textColor)..add('background-color', primaryColor);
```

Theming is pretty easy with a factory function :)

Moreover, it can be more reusable with cache.

```dart
class Theme {
  String primaryColor;
  String textColor;
  Theme(this.primaryColor, this.textColor);
}

final cache = new Expando<Dss>();

ButtonElement themedButton(Theme theme, [String text = 'Click!']) {
  if (cache[theme] == null) {
    cache[theme] = Dss()
      ..add('color', theme.textColor)
      ..add('background-color', theme.primaryColor);
  }
  return ButtonElement()
    ..className = cache[theme].name
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
final redWhenHovered = new Dss()
  ..nest(Dss()
    ..select('&:hover')
    ..add('color', 'red'));

final blue = new Dss()
  ..add('color', 'blue')
  ..compose(redWhenHovered);

final green = new Dss()
  ..add('color', 'green')
  ..compose(redWhenHovered);
```

### Extensibility

If you want a better autocomplete, you can write your own mixin.

```dart
abstract class fontSizeMixin {
  void add(String property, String value);

  void fontSize({num px, num em, num rem}) {
    if (px != null) add('font-size', '${px}px');
    if (em != null) add('font-size', '${em}em');
    if (rem != null) add('font-size', '${rem}rem');
  }
}

class XDss = Dss with fontSizeMixin;

final big = new XDss()..fontSize(rem: 10);
```

## DO NOT USE THIS LIBRARY

This library is usable, but it's more like a proof of concept than a real library. There are tons of issues. There is no test. Browser support is unknown because I only tried this on latest Chrome and Firefox on Linux. There is no benchmark, so this may be too slow and not usable in real life. The problem list goes on... and on.

However, if you think this library has a bright future, please help out by filing issues or submiting PRs. We are gonna make it real together someday :)

[`package:js`]: https://pub.dartlang.org/packages/js
[optional new]: https://github.com/dart-lang/sdk/blob/master/docs/language/informal/optional-new-const.md
[dartdocs.org]: https://www.dartdocs.org/
[docs]: https://furrary.github.io/dss/
[media query]: https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries
[`css.supports`]: https://api.dartlang.org/dev/dart-html/Css/supports.html
[`css.supportscondition`]: https://api.dartlang.org/dev/dart-html/Css/supportsCondition.html

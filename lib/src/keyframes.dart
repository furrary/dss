import 'block_builder.dart';
import 'config.dart';
import 'parser.dart';

/// An abstraction over CSS `@keyframes`.
///
/// This will auto-generate the animation name the same way `Dss` does with its class name.
///
/// You need to call [name] at least once in order to make this rule usable.
///
/// ```dart
/// final fontBulger = new Keyframes()
///   ..add(Frame.list([0, 100])..add('font-size', '10px'))
///   ..add(Frame(50)..add('font-size', '12px'));
///
/// querySelector('querySelector')
///   ..className =
///       (Dss()..add('animation', '${fontBulger.name} 2s infinite')).name
/// ```
class Keyframes {
  String get name {
    _register();
    return _name;
  }

  Keyframes() : _name = Config.nameGenerator.generate();

  /// Creates a named animation.
  ///
  /// I don't know why you would do this, but it's here anyway, just in case.
  Keyframes.named(String name) : _name = name;

  /// Adds a keyframe (step) of this animation.
  void add(Frame frame) {
    _parsedBlock +=
        parseSimpleRule(frame.percentages.join('%,') + '%', frame.declarations);
  }

  bool _isRegistered = false;
  String _name;
  String _parsedBlock = '';

  void _register() {
    if (!_isRegistered) {
      Config.sheet.add('@keyframes $_name{$_parsedBlock}');
      _parsedBlock = '';
      _isRegistered = true;
    }
  }
}

/// An abstraction over a step of the [Keyframes].
class Frame extends Object with BlockBuilder {
  @override
  final List<String> declarations = [];

  /// A list of this keyframe selector.
  ///
  /// `[10, 20]` is equivalent to `10%, 20%`
  final List<num> percentages;

  /// Creates a keyframe with a pecentage selector.
  ///
  /// ```dart
  /// new Frame(10); // 10%
  /// ```
  Frame(num percent) : percentages = [percent];

  /// Creates a keyframe with multiple pecentage selectors.
  ///
  /// ```dart
  /// new Frame.list([0, 100]); // 0%, 100%
  /// ```
  Frame.list(this.percentages);

  /// A syntactic sugar for `0%`.
  Frame.from() : percentages = [0];

  /// A syntactic sugar for `100%`.
  Frame.to() : percentages = [100];
}

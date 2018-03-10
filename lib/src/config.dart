import 'name_generator.dart';
import 'style_sheet.dart';

/// Determine if the web is running in production mode or not.
///
/// To enable production mode, set an environment variable `dss` to `prod`.
///
/// `build.yaml`:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       build_web_compilers|entrypoint:
///         options:
///           compiler: dart2js
///           dart2js_args:
///           - --fast-startup
///           - --minify
///           - --trust-type-annotations
///           - --trust-primitives
///           - -Ddss=prod # This line is needed to enable production mode.
/// ```
const isDev = const String.fromEnvironment('dss') != 'prod';

/// Determine if DSS is running on the server.
///
/// On the server, please set an environment variable `dss` to `server`.
///
/// ```
/// dart main.dart --Ddss=server
/// ```
const isServer = const String.fromEnvironment('dss') == 'server';

/// An [AbstractStyleSheet] which will be used to manipulate CSS styles across the library.
///
/// You can change this to your liking.
AbstractStyleSheet sheet =
    isServer ? new ServerStyleSheet() : new BrowserStyleSheet();

/// A unique class name generator which will be used across the library.
///
/// This defaults to [generateIncrementalName], but you can change it as you please.
NameGenerator generateUniqueName = generateIncrementalName;

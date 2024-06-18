import 'dart:io';

import 'package:args/args.dart';
import 'package:mark/mark.dart';
import 'package:pure/pure.dart';
import 'package:reify/src/hot_reload.dart';
import 'package:reify/src/rule.dart';
import 'package:reify/src/string.dart';

enum Mode {
  local,
  production;

  bool get isLocal => this == Mode.local;

  bool get isProduction => this == Mode.production;
}

({
  String root,
  bool watch,
  List<String> paths,
  Mode mode,
}) _parseArgs(List<String> arguments) {
  const root = 'root';
  const watch = 'watch';
  const paths = 'path';
  const mode = 'mode';

  final parser = ArgParser()
    ..addOption(
      root,
      defaultsTo: '.',
    )
    ..addMultiOption(paths)
    ..addOption(
      mode,
      mandatory: true,
      allowed: Mode.values.map((e) => e.name),
    )
    ..addFlag(
      watch,
    );
  final args = parser.parse(arguments);

  return (
    root: args[root] as String,
    watch: args[watch] as bool,
    paths: args[paths] as List<String>,
    mode: Mode.values.byName(args[mode] as String)
  );
}

class _PrettyEphemeralProcessor extends EphemeralMessageProcessor {
  const _PrettyEphemeralProcessor();

  @override
  String format(LogMessage message) {
    final prefix = message.matchPrimitive(
      primitive: (message) => message.match(
        info: '✅ Info'.constant,
        debug: '🐛 Debug'.constant,
        warning: '❗️ Warning'.constant,
        error: '❌ Error'.constant,
      ),
      orElse: () => '✉️',
    );
    final now = DateTime.now();

    return [
      prefix,
      '${now.hour}:${now.minute}:${now.second}',
      super.format(message),
    ].join(' | ');
  }
}

typedef Context = ({
  String root,
  Mode mode,
});

Future<void> generate(
  List<String> args,
  Rule<String> Function(Context context) rule,
) async {
  final (:root, :watch, :paths, :mode) = _parseArgs(args);
  final context = (root: root, mode: mode);
  final logger = Logger(
    processors: const [
      _PrettyEphemeralProcessor(),
    ],
  );
  final out = Directory(root / 'output');
  Future<void> writeOutput() async {
    try {
      final sw = Stopwatch()..start();
      logger.info('Evaluating rules');
      if (out.existsSync()) {
        logger.info('Clearing output directory');
        await Directory(root / 'output').delete(recursive: true);
      }
      await evalRuleSet(
        logger,
        (
          root: root,
          rule: rule(context),
        ),
      );
      logger.info(
        'Done!',
        meta: {'Elapsed milliseconds': sw.elapsedMilliseconds},
      );
    } on Object catch (e, s) {
      logger.error(
        'Failed to process rule set',
        stackTrace: s,
        meta: (error: e, stackTrace: s),
      );
    }
  }

  await writeOutput();
  if (watch) {
    await watchForHotReload(
      logger,
      paths: {
        root / 'input',
        ...paths,
      },
      onReload: writeOutput,
    ).asFuture<void>();
  }
  await Future(logger.dispose);
}

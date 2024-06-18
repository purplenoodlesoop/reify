import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mark/mark.dart';
import 'package:path/path.dart' as p;
import 'package:pure/pure.dart';
import 'package:reify/src/string.dart';
import 'package:stream_transform/stream_transform.dart';

typedef Item<T> = ({
  String path,
  T data,
});

typedef Items<T> = Iterable<Item<T>>;

typedef RawItem = Item<String>;

sealed class Action<T> {}

typedef ItemsStream<T> = Stream<Item<T>>;

typedef ActionsStream<T> = Stream<Action<T>>;

final class WriteAction<T> implements Action<T> {
  final Item<T> item;

  WriteAction(this.item);
}

final class CopyAction<T> implements Action<T> {
  final File file;

  CopyAction(this.file);
}

typedef RuleDependencies = ({
  Logger logger,
  String root,
});

typedef RuleRunner<O> = ActionsStream<O> Function(
  RuleDependencies dependencies,
);

const input = 'input';

const output = 'output';

extension type Rule<A>(RuleRunner<A> run) {}

/// Copies files from the input directory to the output directory.
Rule<A> copy<A>(String glob) => Rule(
      (dependencies) => p
          .join(dependencies.root, input, glob)
          .pipe(Glob.new)
          .list()
          .whereType<File>()
          .map((file) => file.path)
          .map(p.normalize)
          .map(File.new)
          .map(CopyAction.new),
    );

Rule<A> create<A>(
  Stream<Item<A>> Function(RuleDependencies dependencies) body,
) =>
    Rule((dependencies) async* {
      try {
        yield* body(dependencies).map(WriteAction.new);
      } on Object catch (error, s) {
        dependencies.logger.warning(
          'Failed to create item',
          meta: (error: error),
          stackTrace: s,
        );
      }
    });

/// Writes the output of the rule to the output directory from the root
/// directory.
Rule<O> write<I, O>(RawRuleDescription<I, O> description) =>
    Rule((dependencies) async* {
      final (:logger, :root) = dependencies;

      Iterable<I> safeParse(RawItem input) sync* {
        logger.info('Parsing..', meta: (path: input.path));
        try {
          final value = description.parse(input);
          logger.info('Parsed', meta: (path: input.path));
          yield value;
        } on Object catch (error, s) {
          logger.warning(
            'Failed to parse file',
            meta: (
              path: input.path,
              error: error,
            ),
            stackTrace: s,
          );
        }
      }

      Future<RawItem> readFile(File file) async {
        final path = p.normalize(file.path);
        logger.info('Reading..', meta: (path: path));
        final contents = await file.readAsString();

        return (
          path: path,
          data: contents,
        );
      }

      final sources = await description.input
          ?.pipe((input) => root / 'input' / input)
          .pipe(Glob.new)
          .list()
          .whereType<File>()
          .concurrentAsyncMap(readFile)
          .toList();

      yield* (sources ?? [])
          .expand(safeParse)
          .pipe(description.output)
          .pipe(Stream.fromIterable)
          .map(WriteAction.new);
    });

typedef Parser<A extends Object?, B extends Object?> = B Function(A raw);

typedef OutputDescription<I, O> = Items<O> Function(Iterable<I> input);

typedef WriteRuleDescription< //
        Input extends String?,
        Raw extends Object?,
        Parsed extends Object?,
        Model extends Object?,
        Output extends Object?>
    = ({
  Input input,
  Parser<Raw, Parsed> parse,
  OutputDescription<Model, Output> output,
});

typedef RawRuleDescription<I, O>
    = WriteRuleDescription<String?, RawItem, I, I, O>;

typedef RuleSet = ({
  String root,
  Rule<String> rule,
});

Future<void> evalRuleSet(
  Logger logger,
  RuleSet ruleSet,
) {
  final root = ruleSet.root;

  Future<void> writeOutput(Action<String> output) async {
    switch (output) {
      case WriteAction(:final item):
        final path = const ['input', 'output']
            .map((e) => [root, e, ''])
            .map(p.joinAll)
            .fold(item.path, (acc, prefix) => acc.replaceFirst(prefix, ''));
        final outputPath = p.normalize(p.join(root, 'output', path));

        logger.info('Writing..', meta: (path: outputPath));
        final file = await File(outputPath).create(recursive: true);
        await file.writeAsString(item.data);
      case CopyAction(:final file):
        final prefix = p.join(root, 'input');
        final path = file.path.replaceFirst(p.normalize(prefix) / '', '');
        final outputPath = p.normalize(p.join(root, 'output', path));
        logger.info('Copying..', meta: (path: outputPath));
        await Directory(p.dirname(outputPath)).create(recursive: true);
        await file.copy(outputPath);
    }
  }

  return ruleSet.rule
      .run((logger: logger, root: root))
      .asyncMap(writeOutput)
      .drain();
}

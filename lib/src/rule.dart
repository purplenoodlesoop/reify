import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mark/mark.dart';
import 'package:pure/pure.dart';
import 'package:reify/src/html/core.dart';
import 'package:reify/src/markdown.dart';
import 'package:reify/src/string.dart';
import 'package:stream_transform/stream_transform.dart';

typedef Item<T> = ({
  String path,
  T data,
});

typedef Items<T> = Iterable<Item<T>>;

typedef ItemsStream<T> = Stream<Item<T>>;

typedef RawItem = Item<String>;

typedef OutputDescription<I, O> = Items<O> Function(Iterable<I> input);

typedef RuleDependencies = ({
  Logger logger,
  String prefix,
});

typedef RuleRunner<O> = ItemsStream<O> Function(RuleDependencies dependencies);

extension type Rule<O>(RuleRunner<O> run) {}

typedef WriteRule = Rule<String>;

typedef Rules<T> = Set<Rule<T>>;

typedef ItemParser<I> = I Function(RawItem source);

typedef RuleDescription<I, O> = ({
  String? input,
  ItemParser<I> parse,
  OutputDescription<I, O> output,
});

Rule<O> rule<I, O>(RuleDescription<I, O> description) =>
    Rule((dependencies) async* {
      final (:logger, :prefix) = dependencies;

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
        final path =
            file.path.replaceFirst('$prefix/', '').replaceFirst('./', '');
        logger.info('Reading..', meta: (path: path));
        final contents = await file.readAsString();

        return (
          path: path,
          data: contents,
        );
      }

      final sources = await description.input
          ?.pipe((input) => prefix / input)
          .pipe(Glob.new)
          .list()
          .whereType<File>()
          .concurrentAsyncMap(readFile)
          .toList();

      yield* (sources ?? [])
          .expand(safeParse)
          .pipe(description.output)
          .pipe(Stream.fromIterable);
    });

Rules<B> transform<A, B>({
  required B Function(A input) using,
  required Rules<A> rules,
}) =>
    rules
        .map<Rule<B>>(
          (e) => Rule(
            (dependencies) => e.run(dependencies).map(
                  (e) => (
                    path: e.path,
                    data: using(e.data),
                  ),
                ),
          ),
        )
        .toSet();

WriteRule copy(String input) => rule(
      (
        input: input,
        parse: id,
        output: id,
      ),
    );

WriteRule create(RawItem file) => rule(
      (
        input: null,
        parse: ().constant,
        output: [file].constant,
      ),
    );

Rule<Html> markdown<T>({
  required String input,
  required MetaParser<T> parse,
  required OutputDescription<Markdown<T>, Html> output,
}) =>
    rule(
      (
        input: input,
        parse: (source) => parseMarkdown(parse, source),
        output: output,
      ),
    );

typedef RuleSet = ({
  String root,
  Rules<String> rules,
});

Future<void> evalRuleSet(
  Logger logger,
  RuleSet ruleSet,
) {
  final root = ruleSet.root;
  final prefix = root / 'input';

  Future<void> writeOutput(RawItem output) async {
    logger.info('Writing..', meta: (path: output.path));
    final outputPath = root / 'output' / output.path;
    final file = await File(outputPath).create(recursive: true);
    await file.writeAsString(output.data);
  }

  return Stream.fromIterable(ruleSet.rules)
      .concurrentAsyncExpand(
        (rule) => rule.run((logger: logger, prefix: prefix)),
      )
      .concurrentAsyncMap(writeOutput)
      .drain();
}

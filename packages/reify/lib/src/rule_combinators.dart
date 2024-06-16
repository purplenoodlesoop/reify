import 'package:reify/src/rule.dart';
import 'package:stream_transform/stream_transform.dart';

extension RuleMapX<A> on Rule<A> {
  Rule<B> map<B>(B Function(A a) f) => Rule(
        (dependencies) => run(dependencies).map(
          (rule) => switch (rule) {
            WriteAction(:final item) => WriteAction(
                (
                  path: item.path,
                  data: f(item.data),
                ),
              ),
            CopyAction(:final file) => CopyAction(file),
          },
        ),
      );
}

typedef Rules<A> = Set<Rule<A>>;

typedef _Transform<A, B> = Stream<B> Function(
  Stream<A> stream,
  Stream<B> Function(A a) f,
);

Rule<A> _order<A>(
  Rules<A> rules,
  _Transform<Rule<A>, Action<A>> convert,
) =>
    Rule(
      (dependencies) => convert(
        Stream.fromIterable(rules),
        (rule) => rule.run(dependencies),
      ),
    );

Rule<A> sequential<A>(Rules<A> rules) => _order(
      rules,
      (stream, f) => stream.asyncExpand(f),
    );

Rule<A> concurrent<A>(Rules<A> rules) => _order(
      rules,
      (stream, f) => stream.concurrentAsyncExpand(f),
    );

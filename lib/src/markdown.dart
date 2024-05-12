import 'package:markdown/markdown.dart' as md;
// ignore: implementation_imports
import 'package:markdown/src/charcode.dart';
import 'package:pure/pure.dart';
import 'package:reify/src/html/elements.dart';
import 'package:reify/src/html/parser.dart';
import 'package:reify/src/rule.dart';
import 'package:reify/src/string.dart';
import 'package:yaml/yaml.dart';

typedef ContentNodes = List<md.Node>;

typedef DocumentData = ({
  String title,
  ContentNodes content,
});

typedef Markdown<T extends Object?> = ({
  T meta,
  DocumentData data,
});

class _WikiReference extends md.InlineSyntax {
  static const String _pattern = r'^\[\[(((?!\[)(?!\]).)+)\]\]$';

  _WikiReference() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;

    a(text, href: htmlFileSlug(text))
        .pipe(htmlToMarkdownHtmlNode)
        .pipe(parser.addNode);

    return true;
  }
}

class _HighlightSyntax extends md.DelimiterSyntax {
  _HighlightSyntax()
      : super(
          '==+',
          requiresDelimiterRun: true,
          tags: [md.DelimiterTag('mark', 2)],
          startCharacter: $equal,
        );
}

final _markdownParser = md.Document(
  extensionSet: md.ExtensionSet.gitHubWeb,
  inlineSyntaxes: [
    _WikiReference(),
    _HighlightSyntax(),
  ],
);

typedef FrontMatter = Map<String, Object?>;

typedef MetaParser<T> = T Function(FrontMatter frontMatter);

Markdown<T> parseMarkdown<T>(
  MetaParser<T> parseMeta,
  RawItem source,
) {
  const delimiter = '---';
  const firstDelimiter = delimiter.length;

  final (:data, :path) = source;

  final trimmed = data.trimLeft();
  final closingDelimiter = trimmed.indexOf('\n$delimiter');
  final hasFrontMatter = trimmed.startsWith(delimiter);
  final frontMatterMap = hasFrontMatter
      ? trimmed
          .substring(firstDelimiter, closingDelimiter)
          .pipe((yaml) => (loadYaml(yaml) as YamlMap).cast<String, Object?>())
      : null;
  final markdown = trimmed
      .substring(hasFrontMatter ? firstDelimiter + closingDelimiter + 1 : 0)
      .pipe(_markdownParser.parse);
  final name = path.split('/').last.split('.').first;

  return (
    meta: parseMeta(frontMatterMap ?? const {}),
    data: (
      title: name,
      content: markdown,
    ),
  );
}

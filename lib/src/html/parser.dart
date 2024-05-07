import 'package:markdown/markdown.dart' as md;
import 'package:pure/pure.dart';
import 'package:reify/src/html/core.dart';

md.Node htmlToMarkdownHtmlNode(HtmlNode node) => switch (node) {
      Tag() => md.Element(
          node.name,
          node.children?.map(htmlToMarkdownHtmlNode).toList(),
        )..attributes.addAll(
            node.attributes.map(
              (key, value) => MapEntry(key, value ?? ''),
            ),
          ),
      TextNode() => md.Text(node.text),
    };

String renderHtml(Html html) {
  Iterable<String> renderNode(HtmlNode node) sync* {
    switch (node) {
      case TextNode():
        yield node.text;
      case Tag(:final name, :final children):
        yield '<';
        yield node.name;
        for (final entry in node.attributes.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value != null) {
            yield ' ';
            yield key;
            yield '="';
            yield value;
            yield '"';
          } else {
            yield ' ';
            yield key;
          }
        }
        if (children != null) {
          yield '>';
          yield* children.expand(renderNode);
          yield '</';
          yield name;
          yield '>';
        } else {
          yield '/>';
        }
    }
  }

  final buffer = StringBuffer()
    ..pipe((b) => html.expand(renderNode).pipe(b.writeAll));

  return buffer.toString();
}

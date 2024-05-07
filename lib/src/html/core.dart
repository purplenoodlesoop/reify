import 'package:markdown/markdown.dart' as md;
import 'package:pure/pure.dart';

sealed class HtmlNode {
  factory HtmlNode.raw(List<md.Node> nodes) =>
      md.renderToHtml(nodes).pipe(TextNode.new);
}

typedef Html = Iterable<HtmlNode>;

typedef Attributes = Map<String, String?>;

final class Tag implements HtmlNode {
  final String name;
  final Attributes attributes;
  final Html? children;

  const Tag(
    this.name, {
    this.attributes = const {},
    this.children = const [],
  });

  Tag insertChild(HtmlNode newChild) => Tag(
        name,
        attributes: attributes,
        children: [
          newChild,
          ...?children,
        ],
      );

  Tag addChild(HtmlNode child) => Tag(
        name,
        attributes: attributes,
        children: [
          ...?children,
          child,
        ],
      );
}

final class TextNode implements HtmlNode {
  final String text;

  const TextNode(this.text);
}

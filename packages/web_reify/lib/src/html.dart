import 'package:markdown/markdown.dart' as md;

sealed class HtmlNode {
  factory HtmlNode.raw(List<md.Node> nodes) => TextNode(md.renderToHtml(nodes));
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

  Tag addChild(HtmlNode child) => Tag(
        name,
        attributes: attributes,
        children: [
          ...?children,
          child,
        ],
      );
}

extension StringTag on String {
  Tag call({
    Attributes attributes = const {},
    Html? children = const [],
  }) =>
      Tag(
        this,
        attributes: attributes,
        children: children,
      );

  TextNode get text => TextNode(this);
}

final class TextNode implements HtmlNode {
  final String text;

  const TextNode(this.text);
}

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

  final buffer = StringBuffer()..writeAll(html.expand(renderNode));

  return buffer.toString();
}

Attributes hrefAttr(String href) => {'href': href};

Tag textLink({
  required String text,
  required String href,
}) =>
    'a'(
      children: [text.text],
      attributes: hrefAttr(href),
    );

Tag stylesheet({required String href}) => 'link'(
      attributes: {
        'rel': 'stylesheet',
        ...hrefAttr('$href.css'),
      },
      children: null,
    );

Tag script({required String src}) => 'script'(
      attributes: {
        'src': '$src.js',
      },
    );

Tag h(int level, Html children) => 'h$level'(
      children: children,
    );

Tag meta(Attributes attributes) => 'meta'(
      attributes: attributes,
      children: null,
    );

Tag pair(String key, String value) => Tag(
      key,
      children: [
        value.text,
      ],
    );

Html pairs(List<(String, String)> entries) =>
    entries.map((e) => pair(e.$1, e.$2));

import 'package:brackets/brackets.dart';
import 'package:markdown/markdown.dart' as md;

MarkupNode raw(List<md.Node> nodes) => MarkupText(md.renderToHtml(nodes));

md.Node htmlToMarkdownHtmlNode(MarkupNode node) => switch (node) {
      MarkupTag() => md.Element(
          node.name,
          node.children?.map(htmlToMarkdownHtmlNode).toList(),
        )..attributes.addAll(
            node.attributes.map(
              (key, value) => MapEntry(key, value ?? ''),
            ),
          ),
      MarkupText() => md.Text(node.text),
    };

Attributes hrefAttr(String href) => {'href': href};

MarkupNode textLink({
  required String text,
  required String href,
}) =>
    'a'(
      [text.$],
      attrs: hrefAttr(href),
    );

MarkupNode stylesheet({required String href}) => 'link'(
      null,
      attrs: {
        'rel': 'stylesheet',
        ...hrefAttr('$href.css'),
      },
    );

MarkupNode script({required String src}) => 'script'(
      const [],
      attrs: {
        'src': '$src.js',
      },
    );

MarkupNode h(int level, Markup children) => 'h$level'(
      children,
    );

MarkupNode meta(Attributes attributes) => 'meta'(
      null,
      attrs: attributes,
    );

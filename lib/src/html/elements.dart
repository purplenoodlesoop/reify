import 'package:reify/src/html/core.dart';

Attributes _href(String href) => {'href': href};

Tag stylesheet(String href) => Tag(
      'link',
      attributes: {
        'rel': 'stylesheet',
        ..._href('$href.css'),
      },
      children: null,
    );

Tag script(String src) => Tag(
      'script',
      attributes: {
        'src': '$src.js',
      },
    );

Tag div({
  Html children = const [],
  Attributes attributes = const {},
}) =>
    Tag(
      'div',
      children: children,
      attributes: attributes,
    );

Tag a(String text, {required String href}) => Tag(
      'a',
      attributes: _href(href),
      children: [
        TextNode(text),
      ],
    );

Tag p(String text) => Tag(
      'p',
      children: [
        TextNode(text),
      ],
    );

Tag pMany(Html html) => Tag(
      'p',
      children: html,
    );

Tag nav(Html children) => Tag(
      'nav',
      children: children,
    );

Tag ul(Html children) => Tag(
      'ul',
      children: children,
    );

Tag li(Html children) => Tag(
      'li',
      children: children,
    );

Tag h(int level, String text) => Tag(
      'h$level',
      children: [
        TextNode(text),
      ],
    );

Tag hMany(int level, Html children) => Tag(
      'h$level',
      children: children,
    );

Tag meta(Attributes attributes) => Tag(
      'meta',
      attributes: attributes,
      children: null,
    );

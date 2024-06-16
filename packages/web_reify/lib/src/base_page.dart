import 'package:pure/pure.dart';
import 'package:reify/reify.dart';
import 'package:web_reify/src/html.dart';

Tag _property(String prefix, String key, String content) => meta({
      'property': '$prefix:$key',
      'content': content,
    });

Tag link(Attributes attributes) => 'link'(
      attributes: attributes,
      children: null,
    );

typedef PageInfo = ({
  String fullSite,
  String imageUrl,
  String accentColor,
});

enum OgType {
  website,
  article,
}

typedef PageMeta = ({
  String title,
  OgType type,
  List<String> urlSegments,
  String description,
  List<String> keywords,
  Set<(String, String)> og,
});

typedef PageData = ({
  PageInfo info,
  PageMeta meta,
  Html head,
});

Tag _head(PageData data) {
  final (:info, meta: pageMeta, :head) = data;
  final fullSite = info.fullSite;
  final accentColor = info.accentColor;

  final type = pageMeta.type.name;
  final ogProperty = _property.apply('og');
  final description = pageMeta.description;
  final title = pageMeta.title;
  final url = fullSite / pageMeta.urlSegments.join('/');

  return 'head'(attributes: {
    'prefix': 'og: http://ogp.me/ns# article: http://ogp.me/ns/$type#',
  }, children: [
    meta({
      'charset': 'UTF-8',
    }),
    meta({
      'name': 'viewport',
      'content': 'width=device-width, initial-scale=1.0',
    }),
    'title'(children: [
      title.text,
    ]),
    meta({
      'name': 'description',
      'content': description,
    }),
    meta({
      'name': 'keywords',
      'content': pageMeta.keywords.join(','),
    }),
    link({
      'rel': 'apple-touch-icon',
      'sizes': "180x180",
      'href': "/apple-touch-icon.png",
    }),
    link({
      'rel': 'icon',
      'type': "image/png",
      'sizes': "32x32",
      'href': "/favicon-32x32.png",
    }),
    link({
      'rel': 'icon',
      'type': "image/png",
      'sizes': "16x16",
      'href': "/favicon-16x16.png",
    }),
    link({
      'rel': 'manifest',
      'href': "/site.webmanifest",
    }),
    link({
      'rel': 'mask-icon',
      'href': "/safari-pinned-tab.svg",
      'color': accentColor,
    }),
    meta({
      'name': 'msapplication-TileColor',
      'content': accentColor,
    }),
    ogProperty('title', title),
    ogProperty('description', description),
    ogProperty('url', url),
    ogProperty('type', type),
    ...['image', 'image:url', 'image:secure_url'].map(
      ogProperty.flip.apply(info.imageUrl),
    ),
    ogProperty('image:alt', fullSite),
    ...pageMeta.og.map((e) => _property(type, e.$1, e.$2)),
    ...head,
  ]);
}

Html basePage(
  PageData data, {
  Html children = const [],
  Attributes attrs = const {},
}) =>
    [
      '<!DOCTYPE html>'.text,
      'html'(attributes: {
        'lang': 'en'
      }, children: [
        _head(data),
        'body'(children: children, attributes: attrs),
      ]),
    ];

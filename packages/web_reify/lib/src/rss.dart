import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:reify/reify.dart';
import 'package:web_reify/src/html.dart';
import 'package:web_reify/src/xml.dart';

typedef Author = ({
  String name,
  String email,
  String fullSite,
  String channelTitle,
});

typedef RssItem = ({
  String title,
  String description,
  String link,
  DateTime date,
  List<String> tags,
  String content,
});

final _formatDate = DateFormat('E, dd MMM yyyy HH:mm:ss').format;

Tag _item(Author author, RssItem item) {
  final link = p.join(author.fullSite, item.link);

  return keyValue('item', [
    ('author', '${author.email} (${author.name})'),
    ('title', item.title),
    ('link', link),
    ('guid', link),
    ...item.tags.map((tag) => ('category', tag)),
    ('pubDate', '${_formatDate(item.date)} GMT'),
    ('description', item.description),
    ('content:encoded', '<![CDATA[ ${item.content} ]]>'),
  ]);
}

typedef RssData = ({
  Author author,
  List<RssItem> items,
});

Item<Html> rss(RssData data) {
  final author = data.author;
  final fullSite = author.fullSite;
  final items = data.items.take(20).toList().map(
        (item) => _item(author, item),
      );

  return (
    path: 'rss.xml',
    data: xml([
      'rss'(attributes: {
        'version': '2.0',
        'xmlns:content': 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:atom': 'http://www.w3.org/2005/Atom',
      }, children: [
        'channel'(
          children: [
            ...pairs([
              ('generator', 'Reify'),
              ('language', 'en'),
              ('title', author.channelTitle),
              ('description', 'Articles published on yakov.codes blog.'),
              ('link', fullSite),
              ('copyright', '2024 Yakov Karpov. All rights reserved.'),
              ('ttl', 60.toString()),
            ]),
            'atom:link'(
              children: null,
              attributes: {
                'href': fullSite / 'rss.xml',
                'rel': 'self',
                'type': 'application/rss+xml',
              },
            ),
            ...items,
          ],
        ),
      ]),
    ]),
  );
}

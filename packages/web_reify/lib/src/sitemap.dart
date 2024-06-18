import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:pure/pure.dart';
import 'package:reify/reify.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web_reify/src/html.dart';
import 'package:web_reify/src/shared.dart';
import 'package:web_reify/src/xml.dart';

typedef SitemapInfo = ({
  String fullSite,
  Map<String, double> priorities,
  String changefreq,
});

typedef SitemapPage = ({
  DateTime lastModified,
  String path,
});

final formatter = DateFormat('yyyy-MM-dd');

HtmlNode _url(SitemapInfo info, SitemapPage page) {
  final path = page.path;
  final loc = path
      .replaceFirst('.html', '')
      .pipe((path) => path == 'index' ? '' : path);
  final priority = info.priorities.entries
      .firstWhere((priority) => path.startsWith(priority.key))
      .value
      .toString();

  return keyValue('url', [
    ('loc', info.fullSite / loc),
    ('lastmod', formatter.format(page.lastModified)),
    ('changefreq', info.changefreq),
    ('priority', priority)
  ]);
}

Rule<Html> writeSitemap(SitemapInfo info) => create((dependencies) async* {
      final prefix = dependencies.root / 'output';
      final pages = await Glob(prefix / '**.html')
          .list()
          .whereType<File>()
          .concurrentAsyncMap((file) async => (
                path: file.path.replaceFirst('$prefix/', '').pipe(p.normalize),
                lastModified: await file.lastModified(),
              ))
          .toList();

      yield (
        path: sitemap,
        data: xml([
          'urlset'(
            attributes: {
              'xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9',
            },
            children: pages.map((page) => _url(info, page)),
          )
        ]),
      );
    });

import 'package:reify/reify.dart';
import 'package:web_reify/src/copy_static.dart';
import 'package:web_reify/src/html.dart';
import 'package:web_reify/src/markdown.dart';
import 'package:web_reify/src/robots.dart';
import 'package:web_reify/src/sitemap.dart';

Iterable<Rule<String>> _html(Rules<Html> rules) =>
    rules.map((rule) => rule.map(renderHtml));

typedef SiteData = ({
  String fullSite,
  Map<String, String> robots,
  Map<String, int> sitemap,
  String changefreq,
  Set<MarkdownRuleDescription<Html>> pages,
});

Rule<String> createSite(SiteData data) {
  final fullSite = data.fullSite;

  return sequential({
    concurrent({
      copyStatic(),
      createRobotsTxt((fullSite: data.fullSite, entries: data.robots)),
      ..._html(data.pages.map(markdown).toSet()),
    }),
    ..._html({
      writeSitemap((
        fullSite: fullSite,
        priorities: data.sitemap,
        changefreq: data.changefreq,
      )),
    })
  });
}

import 'package:reify/reify.dart';
import 'package:web_reify/src/shared.dart';

typedef RobotsData = ({
  String fullSite,
  Map<String, String> entries,
});

Rule<String> createRobotsTxt(
  RobotsData data,
) =>
    create((_) {
      final values = {'Sitemap': data.fullSite / sitemap, ...data.entries};

      return (
        path: 'robots.txt',
        data: values.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
      );
    });

import 'package:reify/reify.dart';

Rule<String> copyStatic() {
  const static = [
    '*.png',
    'favicon.ico',
    'browserconfig.xml',
    'site.webmanifest',
    '*.scg',
    'assets/',
    'css/**.css',
  ];

  return concurrent(
    static.map(copy<String>).toSet(),
  );
}

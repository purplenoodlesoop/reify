extension StringPathX on String {
  String operator /(String other) => '$this/$other';
}

String slugify(String name) => name.toLowerCase().replaceAll(' ', '-');

String htmlFileSlug(String name) => '${slugify(name)}.html';

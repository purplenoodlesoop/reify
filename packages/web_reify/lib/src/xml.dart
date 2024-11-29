import 'package:brackets/brackets.dart';

MarkupNode keyValue(String tag, List<(String, String)> entries) => tag.call(
      pairs(entries),
    );

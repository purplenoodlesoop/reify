import 'package:web_reify/src/html.dart';

Html xml(Html children) => [
      '<?xml version="1.0" encoding="UTF-8"?>'.text,
      ...children,
    ];

Tag keyValue(String tag, List<(String, String)> entries) => tag(
      children: pairs(entries),
    );

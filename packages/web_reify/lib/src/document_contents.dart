import 'package:markdown/markdown.dart' as md;
import 'package:web_reify/src/html.dart';
import 'package:web_reify/src/markdown.dart';

typedef _State = (Tag, List<md.Element>);

Tag _entry(String text, String id) =>
    'li'(children: [textLink(text: text, href: '#$id')]);

_State _processRoot(
  List<md.Element> elements,
  int currentLevel,
) =>
    _process(
      elements,
      currentLevel,
      'ul'(),
    );

_State _process(
  List<md.Element> elements,
  int currentLevel,
  Tag currentNode,
) {
  late final terminate = (currentNode, elements);

  return switch (elements) {
    [final nextElement, ...final rest] => () {
        _State recurse(List<md.Element> rest, Tag node) => _process(
              rest,
              currentLevel,
              node,
            );

        final parts = nextElement.tag.split('');
        final nextLevel = int.tryParse(parts.last);
        final isHeader =
            parts.length == 2 && parts.first == 'h' && nextLevel != null;

        /// Not a header, continue processing.
        if (!isHeader) return recurse(rest, currentNode);

        /// Header level is less than current level, we have reached the end
        /// of the nested list.
        if (nextLevel < currentLevel) return terminate;

        /// Header level is greater than current level, recurse with a new
        /// list root for the nested list.
        if (nextLevel > currentLevel) {
          final (subIndex, newRest) = _processRoot(elements, nextLevel);

          return recurse(
            newRest,
            currentNode.addChild(subIndex),
          );
        }

        /// Header level is equal to current level, add the header to the
        /// current list.
        return recurse(
          rest,
          currentNode.addChild(
            _entry(
              nextElement.textContent,
              nextElement.generatedId!,
            ),
          ),
        );
      }(),
    [] => terminate,
  };
}

typedef DocumentContentData = ({
  ContentNodes nodes,
  int initialLevel,
});

HtmlNode documentContents(DocumentContentData data) {
  final elements = data.nodes.whereType<md.Element>().toList();
  final (indexElement, _) = _processRoot(elements, data.initialLevel);

  return indexElement;
}

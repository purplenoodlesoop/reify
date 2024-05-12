import 'package:path/path.dart';
import 'package:reify/reify.dart';

String htmlFile(String path) =>
    setExtension(withoutExtension(basename(path)), '.html');

void main(List<String> arguments) => generate(
      arguments,
      (context) => concurrent({
        copy('**.txt'),
        write<RawItem, String>((
          input: 'md/**.md',
          parse: (raw) => raw,
          output: (data) => data.map((e) => (
                path: htmlFile(e.path),
                data: e.data * 2,
              )),
        )),
        create(() => (
              path: 'timestamp.json',
              data: '"${DateTime.now().toIso8601String()}"',
            ))
      }),
    );

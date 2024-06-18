import 'package:path/path.dart';
import 'package:reify/reify.dart';

void main(List<String> arguments) => generate(
      arguments,
      (context) => concurrent({
        copy('static/**.txt'),
        write<RawItem, String>((
          input: 'md/**.md',
          parse: (raw) => raw,
          output: (data) => data.map((e) => (
                path: setExtension(basenameWithoutExtension(e.path), '.html'),
                data: e.data * 2,
              )),
        )),
        create((_) async* {
          yield (
            path: 'timestamp.json',
            data: '"${DateTime.now().toIso8601String()}"',
          );
        })
      }),
    );

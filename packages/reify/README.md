# Reify

Reify is a declarative data processing toolkit for Dart. It provides a pure, composable, combinator-based interface for local, managed data mutations. Reify is designed to be flexible and can be used for various purposes such as static site generators, build systems, and code generators.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Static Site Generators](#static-site-generators)
  - [Build Systems](#build-systems)
  - [Code Generators](#code-generators)
- [CLI Bootstrapping](#cli-bootstrapping)
- [License](#license)

## Features

- **Declarative Data Processing**: Manage data mutations through a pure, composable, combinator-based interface.
- **Flexible Use Cases**: Suitable for static site generators, build systems, code generators, and more.
- **Combinator Interface**: Provides a set of combinators for defining complex data processing pipelines in a concise and readable manner.
- **CLI Bootstrapping**: Provides a function to bootstrap CLI with arguments handling and optional hot reload in debug mode.
- **Nix Build System**: Utilizes Nix for efficient and reproducible builds.
- **Live and Hot Reload**: Incorporates Dart VM-provided live and hot reload functionality.

## Getting Started

To use Reify in your Dart project, follow these steps:

1. Create a new Dart project.
2. Add the Reify package in your `pubspec.yaml` file.
3. Optionally, start the development environment using `nix develop`, and utilize `lib.watch` function from `flake.nix`.

## Usage

### Static Site Generators

Reify can be used to create static site generators by processing Markdown files and generating HTML output.

```dart
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
```

### Build Systems

Reify can be integrated into build systems to manage and automate various build tasks.

### Code Generators

Reify can be used to create code generators that process input files and generate code based on predefined rules.

## CLI Bootstrapping

Reify provides a function to bootstrap CLI with arguments handling and optional hot reload in debug mode.

```dart
import 'package:reify/reify.dart';

void main(List<String> arguments) => generate(
      arguments,
      (context) => concurrent({
        // Define your rules here
      }),
    );
```

# web_reify

web_reify is a static site generator for Dart, powered by the `reify` package. It provides a flexible and declarative approach to generating static websites from Markdown files and other assets.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Running the Generator](#running-the-generator)
- [Functions](#functions)
  - [Copy Static Assets](#copy-static-assets)
  - [Generate Markdown Table of Contents](#generate-markdown-table-of-contents)
  - [Convert Markdown to HTML](#convert-markdown-to-html)
  - [Generate robots.txt](#generate-robotstxt)
  - [Generate RSS Feed](#generate-rss-feed)
  - [Generate Sitemap](#generate-sitemap)
- [createSite Function](#createsite-function)
- [License](#license)

## Features

- **Markdown Processing**: Convert Markdown files to HTML.
- **Static Asset Management**: Copy static assets to the output directory.
- **Sitemap Generation**: Automatically generate a sitemap for your site.
- **Robots.txt Generation**: Create a `robots.txt` file for your site.
- **RSS Feed Generation**: Generate an RSS feed for your site's content.
- **Hot Reload**: Supports hot reload for efficient development.

## Getting Started

To use web_reify in your Dart project, follow these steps:

1. Create a new Dart project.
2. Add the `web_reify` package to your `pubspec.yaml` file.

## Usage

### Basic Example

Create a Dart file (e.g., `main.dart`) with the following content:

```dart
import 'package:web_reify/web_reify.dart';

void main(List<String> arguments) => generate(
      arguments,
      (context) => createSite(
        (
          fullSite: 'https://example.com',
          robots: {'User-agent': '*', 'Disallow': ''},
          sitemap: {'/': 1.0},
          changefreq: 'daily',
          pages: {
            markdown(
              (
                input: 'content/**.md',
                parse: (frontMatter) => frontMatter,
                output: (data) => data.map((e) => (
                      path: '${e.data.title}.html',
                      data: e.data.content.render(),
                    )),
              ),
            ),
          },
        ),
      ),
    );
```

### Running the Generator

Run the generator using the Dart CLI:

```sh
dart run main.dart
```

## Functions

### Copy Static Assets

Use the `copyStatic` function to copy static assets to the output directory.

### Generate Markdown Table of Contents

Use the `documentContents` function to create a table of contents from Markdown files.

### Convert Markdown to HTML

Use the `markdown.dart` library to convert Markdown files to HTML and work with them as structured Dart Records.

### Generate robots.txt

Use the `createRobotsTxt` function to generate a `robots.txt` file for your site.

### Generate RSS Feed

Use the `generateRSS` function to create an RSS feed for your site's content.

### Generate Sitemap

Use the `writeSitemap` function to generate a sitemap for your site.

## createSite Function

The `createSite` function integrates all the basic functionalities provided by web_reify, including copying static assets, processing Markdown files, generating a sitemap, and creating a `robots.txt` file. This function simplifies the process of setting up a static site generator by combining these features into a single, cohesive workflow.

# Reify

Reify is a microframework designed for building static sites without the use of templates. It leverages an embedded domain-specific language (eDSL) to describe pages, allowing for a flexible and customizable approach to site creation. Content is managed using Markdown files with custom, arbitrary frontmatter, enabling easy content organization.

## Features

- **Microframework for Static Sites**: Reify provides a lightweight solution for creating static sites.
- **eDSL for Page Description**: The use of an embedded domain-specific language allows for detailed and specific page descriptions.
- **Markdown Content**: Content is stored in Markdown files, with the flexibility of custom frontmatter for enhanced content management.
- **Nix Build System**: Utilizes Nix as a build system and package manager, ensuring efficient and reproducible builds.
- **Live and Hot Reload**: Incorporates Node live-server for live and hot reload functionality, making development and testing seamless.

## Getting Started

To use the project, follow these steps:

1. Create a new dart project.
2. Add the Reify package in your `pubspec.yaml` file.
3. Optionally, start the development environment using `nix develop`.
4. Start the watch mode using `develop.nix` to enable live and hot reload features.

---

For detailed instructions on installation and usage, please refer to the repository files.

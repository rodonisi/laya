# Kover

An unofficial cross-platform Kavita frontend.

## Getting Started

### Building from Source

This project makes heavy use of code generation for APIs and model objects. The generated code is also not committed to the repository, so building from source requires a few extra steps:

- First off, install dependencies with

  ```bash
  flutter pub get
  ```

- then generate api clients and dtos

  ```bash
  dart run swagger_parser
  ```

- and then run build_runner to generate all annotated code

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- finally the project can be build as usual with `flutter build` or run in debug mode with `flutter run`

Note: remember to regenerate code when modifying annotated classes or run with `dart run build_runner watch
--deleteAlso-conflicting-outputs` during development to watch for changes.

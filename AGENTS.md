# AGENTS.md

## Project

Flutter app (Dart SDK ^3.12.1). Single-package, no monorepo.

## Commands

- Run: `flutter run`
- Test: `flutter test`
- Analyze (lint): `flutter analyze`
- Fix lint: `dart fix --apply`
- Get deps: `flutter pub get`

## Structure

- Entrypoint: `lib/main.dart`
- Lint config: `analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`)

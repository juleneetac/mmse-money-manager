# myapp

A new Flutter project.

## Getting Started

After adding dependencies in pubsec.yaml:
flutter pub get

When chanchin the schem from the database file:
flutter pub run build_runner build  (deprecated)
--> (better) dart run build_runner build --delete-conflicting-outputs
or
1 flutter pub get
2 dart run build_runner build

put sqlite3.wasm and drift_worker.js into your web/ folder so the browser knows how to handle the database ( drift_dev: ^2.22.0):
dart run drift_dev download-wasm
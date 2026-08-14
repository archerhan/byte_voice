#!/bin/bash
# Run with use_framework=1 to fix OBJC_CLASS_$_NSArray symbol resolution issue
flutter run --dart-define=use_framework=1 "$@"

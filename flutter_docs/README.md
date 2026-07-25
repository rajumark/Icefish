# Flutter Documentation

Flutter development best practices and guides.

## Files

| File | Description |
|------|-------------|
| [best_practices.md](best_practices.md) | Project structure & conventions |
| [desktop_development.md](desktop_development.md) | Desktop platform guides |
| [state_management.md](state_management.md) | State management solutions |

## Quick Reference

### Project Structure (Feature-First)
```
lib/
├── core/
├── features/
│   └── feature_name/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

### Key Commands
```bash
# Enable desktop
flutter config --enable-macos-desktop

# Run desktop
flutter run -d macos

# Build desktop
flutter build macos
```

### State Management Choice
- **Riverpod**: Most apps (recommended)
- **BLoC**: Complex enterprise apps
- **Signals**: High-frequency updates
- **GetX**: Quick prototyping

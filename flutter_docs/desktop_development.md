# Flutter Desktop Development

## Platform Support

Flutter supports desktop development for:
- **Windows**: Windows 7 or later
- **macOS**: macOS 10.14 (Mojave) or later
- **Linux**: Ubuntu 18.04 or later

## Enable Desktop Support

```bash
# Enable all desktop platforms
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Check available devices
flutter devices
```

## Run Desktop Apps

```bash
# Run on specific platform
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Run on all available platforms
flutter run -d windows
```

## Window Management

### macOS (MainFlutterWindow.swift)
```swift
// Maximize window on launch
self.zoom(self)
```

### Windows (main.cpp)
```cpp
// Maximize window on launch
::ShowWindow(window.GetHandle(), SW_MAXIMIZE);
```

### Linux (my_application.cc)
```c
// Maximize window on launch
gtk_window_maximize(window);
```

## Desktop-Specific Features

### Window Properties
- Title bar customization
- Window size/position
- Always on top
- Full screen mode

### Native Integration
- File system access
- System tray
- Notifications
- Keyboard shortcuts

## Build for Desktop

```bash
# Build macOS app
flutter build macos

# Build Windows app
flutter build windows

# Build Linux app
flutter build linux
```

## Testing Desktop

```bash
# Run tests
flutter test

# Run on specific device
flutter test -d macos
```

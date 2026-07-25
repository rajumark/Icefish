# Run & Deploy Commands

Deploy and run Android applications on devices.

## Run App

```bash
# Run on connected device
android run

# Run in debug mode
android run --debug

# Run specific activity
android run --activity=com.example.MyActivity

# Run on specific device
android run --device=emulator-5554

# Install APK
android run --apks=path/to/app.apk
```

## Options

| Option | Description |
|--------|-------------|
| `--debug` | Run in debug mode |
| `--activity` | Specific activity to launch |
| `--device` | Target device serial number |
| `--apks` | APK file paths to install |
| `--type` | Component type (ACTIVITY, SERVICE, etc.) |

## Workflow

```bash
# 1. Build your app
flutter build apk

# 2. Deploy to device
android run --apks=build/app/outputs/flutter-apk/app-debug.apk
```

# Android CLI Overview

The Android CLI is a command-line tool for Android development that helps you:
- Create new Android projects
- Run Android apps on devices
- Manage Android virtual devices (emulators)
- Manage Android SDK components
- Capture screenshots and inspect UI layouts
- Search Android documentation
- Integrate with Android Studio

## Installation

```bash
# Mac Arm
curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh | bash

# Mac Intel
curl -fsSL https://dl.google.com/android/cli/latest/darwin_x86_64/install.sh | bash

# Linux
curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install.sh | bash

# Windows
curl -fsSL https://dl.google.com/android/cli/latest/windows_x86_64/install.cmd -o "%TEMP%\i.cmd" && "%TEMP%\i.cmd"
```

## Main Commands

| Command | Description |
|---------|-------------|
| `android create` | Create new Android project |
| `android run` | Deploy app to device |
| `android emulator` | Manage virtual devices |
| `android screen` | Capture screenshots |
| `android layout` | Inspect UI layout |
| `android sdk` | Manage SDK packages |
| `android docs` | Search documentation |
| `android studio` | Android Studio integration |
| `android skills` | Manage agent skills |
| `android info` | Print environment info |

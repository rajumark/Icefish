# SDK Management

Manage Android SDK packages and tools.

## Commands

### List Packages
```bash
# List installed and available packages
android sdk list
```

### Install Packages
```bash
# Install specific package
android sdk install platforms/android-34

# Install specific version
android sdk install build-tools/34.0.0

# Install multiple packages
android sdk install platforms/android-34 platforms/android-35
```

### Update Packages
```bash
# Update specific package
android sdk update build-tools

# Update all packages
android sdk update
```

### Remove Packages
```bash
android sdk remove <package-name>
```

## Common Packages

| Package | Description |
|---------|-------------|
| `platform-tools` | ADB, fastboot, etc. |
| `build-tools` | Build tools for APK |
| `platforms/android-XX` | Platform APIs |
| `emulator` | Android Emulator |
| `system-images` | OS images for emulators |

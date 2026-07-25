# Emulator Management

Manage Android Virtual Devices (AVDs) for testing.

## Commands

### List Emulators
```bash
android emulator list
```

### Start Emulator
```bash
android emulator start <device-name>
```

### Stop Emulator
```bash
android emulator stop <device-name>
```

### Create Emulator
```bash
android emulator create
```

### Remove Emulator
```bash
android emulator remove <device-name>
```

## Common Workflow

```bash
# 1. List available emulators
android emulator list

# 2. Start an emulator
android emulator start Pixel_6

# 3. Run your app on the emulator
flutter run -d emulator-5554

# 4. Stop the emulator when done
android emulator stop Pixel_6
```

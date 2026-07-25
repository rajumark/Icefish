# Screen & Layout Commands

Capture screenshots and inspect UI layouts.

## Screen Capture

```bash
# Capture screenshot
android screen capture

# Output: screenshot.png in current directory
```

## UI Layout Inspection

```bash
# Get full layout tree
android layout

# Pretty-print JSON output
android layout --pretty

# Save to file
android layout --output=layout.json

# Show changes since last dump
android layout --diff

# Specify device
android layout --device=emulator-5554
```

## Use Cases

- **Debug UI issues**: Inspect layout hierarchy without screenshots
- **Automated testing**: Capture screenshots for visual regression tests
- **Layout comparison**: Use `--diff` to see what changed between interactions

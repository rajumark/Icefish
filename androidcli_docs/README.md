# Android CLI Documentation

Documentation for Android CLI capabilities and features.

## Files

| File | Description |
|------|-------------|
| [01_overview.md](01_overview.md) | Overview and installation |
| [02_create_project.md](02_create_project.md) | Creating new projects |
| [03_emulator.md](03_emulator.md) | Emulator management |
| [04_screen_layout.md](04_screen_layout.md) | Screen capture & layout inspection |
| [05_sdk_management.md](05_sdk_management.md) | SDK package management |
| [06_skills.md](06_skills.md) | Agent skills management |
| [07_studio_integration.md](07_studio_integration.md) | Android Studio integration |
| [08_run_deploy.md](08_run_deploy.md) | Running & deploying apps |

## Common Use Case: Create Theme

When creating themes for Android apps, you can use:

1. **Project Creation**: Start with `android create --name="Theme App"`
2. **Skills**: Install theming skills with `android skills find theme`
3. **Documentation**: Search for theme docs with `android docs search Material Design theme`
4. **Preview**: Render Compose previews with `android studio render-compose-preview`

### Theme Customization Workflow

```bash
# 1. Create project
android create --name="My Theme App"

# 2. Search for Material Design documentation
android docs search Material Design color theme

# 3. Find available theming skills
android skills find theme styles

# 4. Preview your theme changes
android studio render-compose-preview
```

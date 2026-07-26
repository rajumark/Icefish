# Icefish Feature Documentation

## Overview
Icefish is a Flutter desktop application that wraps the Android CLI into a GUI for easy human control of Android development tools. This document details every feature per screen for testing purposes.

---

## 1. Splash Screen

### Features
- **CLI Detection**: Checks if `android` CLI is installed at `~/.local/bin/android`
- **Version Check**: Runs `android --version` to verify CLI works
- **Routing**: Routes to Setup screen if CLI missing, Home screen if available
- **No Animation**: Simple status text display, no animations

### CLI Commands Used
- `android --version`

---

## 2. Setup Screen

### Features
- **Missing CLI Detection**: Shows error state when CLI not found
- **Install Button**: Downloads and runs Android CLI install script
- **Progress Indicator**: Shows download/install progress
- **Error Handling**: Displays error message if install fails
- **Navigation**: Skip button to proceed without CLI

### CLI Commands Used
- Install script: `curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh | bash`

---

## 3. Home Screen

### Features
- **CLI Version Display**: Shows installed Android CLI version
- **SDK Path Display**: Shows Android SDK location
- **Launcher Version**: Shows Icefish app version
- **Refresh Button**: Reloads CLI information
- **Settings Access**: Opens theme settings dialog

### CLI Commands Used
- `android --version`
- `android info`

---

## 4. Settings Dialog

### Features
- **Theme Switcher**: System/Light/Dark mode selection
- **Persistent Storage**: Saves theme preference with SharedPreferences
- **Instant Apply**: Theme changes apply immediately
- **Material3**: Uses Material3 design system

### Data Flow
- SharedPreferences → SettingsProvider → MaterialApp theme

---

## 5. Navigation Rail

### Features
- **10 Screens**: Home, Create, Emulator, Run, SDK, Screen, Layout, Skills, Docs, Studio
- **IndexedStack**: Preserves screen state when switching tabs
- **Active Indicator**: Highlights current screen
- **Responsive**: Adapts to window size

---

## 6. Create Project Screen

### Features
- **3-Step Wizard**: Project Info → Template → Options
- **Project Name Validation**: Must start with letter, use only letters/numbers/_/-
- **Organization Field**: Sets project organization (e.g., com.example)
- **Description Field**: Project description
- **Template Search**: Filter available templates
- **Quick Presets**: Empty, Full, Minimal templates
- **Min SDK Selector**: Android minimum SDK version
- **Output Path**: Custom output directory
- **Git Init Toggle**: Initialize git repository
- **Confirmation Dialog**: Confirms before creating
- **Copy Path**: Copy project path to clipboard

### CLI Commands Used
- `android create --list`
- `android create --name="ProjectName" --org=com.example --minSdk=21`

---

## 7. Emulator Screen

### Features
- **Running Status**: Shows which emulators are running with green dot
- **Auto-Refresh**: Checks running status every 5 seconds
- **Start/Stop Toggle**: Start or stop individual emulators
- **Stop All**: Stop all running emulators at once
- **Create Emulator**: Create new emulator with custom name
- **Remove Emulator**: Delete emulator (with confirmation)
- **Take Screenshot**: Capture screenshot from running emulator
- **Install APK**: Install APK to specific emulator
- **Emulator Info**: View device details
- **Copy ID**: Copy emulator name/ID to clipboard
- **Context Menu**: Bottom sheet with all actions per emulator
- **Running Count Badge**: Shows number of running emulators

### CLI Commands Used
- `android emulator list`
- `android emulator start <name>`
- `android emulator stop <name>`
- `android emulator create <name>`
- `android emulator remove <name>`
- `android screen capture --device=<id>`
- `android run --apks=<path> --device=<id>`

---

## 8. Run/Deploy Screen

### Features
- **Device Selector**: Dropdown with auto-detected devices
- **APK Browser**: Quick-select APK variants (debug/release/profile)
- **Package Name Field**: For uninstall/permissions
- **Debug/Release Toggle**: Build variant selection
- **Uninstall First**: Remove old app before install
- **Clear Data**: Clear app data before install
- **Grant Permissions**: Auto-grant all permissions
- **Quick Actions**: Build & Run, Clear Data, Screenshot, Device Info
- **Run History**: Last 10 deployments with restore
- **Confirmation Dialog**: Confirms before deploy
- **Copy APK Path**: Copy path to clipboard
- **Progress Indicators**: Shows deployment progress

### CLI Commands Used
- `android devices`
- `android run --apks=<path> --debug --device=<id>`
- `android run --uninstall=<package> --device=<id>`
- `android run --clear-data --device=<id>`
- `android run --grant-all --package=<pkg> --device=<id>`
- `android screen capture`

---

## 9. SDK Manager Screen

### Features
- **Table View**: Proper table with columns (Package, Type, Status, Actions)
- **Package Count Badge**: Shows total packages
- **Search/Filter**: Search by name or type
- **Sortable Columns**: Click headers to sort (name, type, status)
- **Multi-Select**: Checkbox selection for bulk operations
- **Select All Toggle**: Select/deselect all filtered packages
- **Bulk Update**: Update all selected packages
- **Bulk Remove**: Remove all selected packages
- **Quick Install Chips**: Common packages (platforms, build-tools, etc.)
- **Package Info**: Type detection (Build Tools, Platform Tools, Emulator, etc.)
- **Status Indicators**: Installed (green) vs Available (grey)
- **Type Badges**: Color-coded package types
- **Copy Name**: Copy package name to clipboard
- **Export List**: Copy all packages as JSON
- **Install Dialog**: Install custom package with suggestions

### CLI Commands Used
- `android sdk list`
- `android sdk install <package>`
- `android sdk update <package>`
- `android sdk remove <package>`

---

## 10. Screen Capture Screen

### Features
- **Screenshot Capture**: Capture device screenshot
- **Screenshot Preview**: Display captured image
- **UI Element Resolution**: View UI hierarchy
- **UI Hierarchy Copy**: Copy hierarchy to clipboard
- **Screen Recording**: Start/stop video recording
- **Screen Rotation**: Portrait/Landscape/Auto rotate
- **Brightness Control**: Slider to adjust device brightness
- **Tap at Coordinates**: Tap specific screen coordinates
- **Swipe Gesture**: Perform swipe with start/end coordinates
- **Input Text**: Type text on device
- **Key Press**: Home/Back/Recent/Power/Volume keys
- **Screenshot History**: View and restore previous screenshots
- **Side-by-Side View**: UI hierarchy + Screenshot together

### CLI Commands Used
- `android screen capture`
- `android screen resolve`
- `android screen record --start`
- `android screen record --stop`
- `android screen rotate <direction>`
- `android screen brightness <value>`
- `android screen tap <x> <y>`
- `android screen swipe <x1> <y1> <x2> <y2>`
- `android screen input "<text>"`
- `android screen key <key>`

---

## 11. Layout Inspector Screen

### Features
- **Layout Tree Display**: View UI hierarchy tree
- **Layout Diff**: Compare layout changes
- **Pretty Print Toggle**: Format output for readability
- **Search in Layout**: Find specific views
- **Filter by Type**: TextView, ImageView, Button, EditText, RecyclerView
- **Copy to Clipboard**: Copy layout tree
- **Export as JSON**: Export layout data
- **View Count Badge**: Total views in hierarchy
- **Max Depth Display**: Tree depth indicator
- **Statistics Dialog**: View count, depth, history count
- **Layout History**: Previous layout captures
- **Selectable Text**: Easy text selection

### CLI Commands Used
- `android layout`
- `android layout --pretty`
- `android layout --diff`
- `android layout --history`

---

## 12. Skills Screen

### Features
- **Skill Count Badge**: Total installed skills
- **Search/Filter**: Search skills by name
- **Multi-Select**: Checkbox selection
- **Select All Toggle**: Select/deselect all
- **Bulk Install**: Install all selected skills
- **Bulk Remove**: Remove all selected skills
- **Skill Info Dialog**: View skill details
- **Copy Skill Name**: Copy to clipboard
- **Install Dialog**: Install custom skill
- **Individual Install/Remove**: Per-skill actions
- **Clear Search**: Reset search filter
- **Confirmation Dialogs**: Confirm destructive actions

### CLI Commands Used
- `android skills list`
- `android skills find <query>`
- `android skills add <name>`
- `android skills remove <name>`

---

## 13. Documentation Screen

### Features
- **Search Documentation**: Search Android docs
- **Fetch by URL**: Fetch specific documentation URL
- **Search in Results**: Filter current results
- **Copy to Clipboard**: Copy documentation text
- **Bookmark Results**: Save documentation for later
- **View Bookmarks**: Access saved bookmarks
- **Search History**: Previous searches
- **Quick Topics**: Emulator, Build Tools, ADB, SDK, Gradle, Signing
- **Font Size Adjustment**: Increase/decrease text size
- **Word Wrap Toggle**: Enable/disable line wrapping
- **Line Count**: Show number of lines in result
- **Selectable Text**: Easy text selection

### CLI Commands Used
- `android docs search <query>`
- `android docs fetch <url>`
- `android docs --history`
- `android docs --bookmarks`

---

## 14. Studio Screen

### Features
- **Search Actions**: Find studio actions
- **Action History**: Previous actions with restore
- **Favorites System**: Star/unstar frequently used actions
- **Quick Actions**: Build, Clean, Run, Debug, Test, Format
- **Check Status**: Verify Android Studio connection
- **Find Declaration**: Look up symbol declaration
- **Find Usages**: Find where symbol is used
- **Open File**: Open file in Android Studio
- **Analyze File**: Run code analysis
- **Version Lookup**: Check library versions
- **Copy Result**: Copy action result to clipboard
- **Selectable Result**: Easy text selection

### CLI Commands Used
- `android studio check`
- `android studio find-declaration <symbol>`
- `android studio find-usages <symbol>`
- `android studio open-file <path>`
- `android studio analyze-file <path>`
- `android studio version-lookup <artifact>`
- `android studio render-compose-preview`
- `android studio build`
- `android studio clean`
- `android studio run`
- `android studio debug`
- `android studio test`
- `android studio format`

---

## 15. Core Services

### CliService
- **Command Execution**: Runs Android CLI commands
- **Quote-Aware Parsing**: Handles quoted arguments
- **Timeout**: 5-minute timeout per command
- **Result Type**: CliResult with success, output, error fields
- **Mounted Check**: Prevents state updates after dispose

### CliChecker
- **Installation Check**: Verifies CLI is installed
- **Path Detection**: Finds CLI at ~/.local/bin/android
- **Version Detection**: Gets CLI version

### SettingsProvider
- **Theme Persistence**: Saves/loads theme mode
- **SharedPreferences**: Uses shared_preferences package
- **Reactive Updates**: Notifies listeners on change

---

## 16. Reusable Widgets

### StatusBanner
- **Types**: Info, Success, Error, Loading
- **Colors**: Type-specific background colors
- **Dismissable**: Close button to hide
- **Auto-Clear**: Clears after delay (optional)

### ConfirmDialog
- **Destructive Actions**: Confirmation before dangerous operations
- **Custom Labels**: Customizable button text
- **Custom Colors**: Customizable confirm button color

### ResultCard
- **Display Results**: Shows command output
- **Scrollable**: Scroll long content
- **Title**: Card header

### ActionButton
- **Reusable Button**: Consistent button styling
- **Icon + Label**: Icon and text combination
- **Loading State**: Shows progress indicator

---

## Testing Strategy

### Unit Tests
- CliService command parsing
- SettingsProvider persistence
- Package type detection
- Name validation

### Widget Tests
- Each screen renders correctly
- User interactions trigger correct callbacks
- Loading states display properly
- Error states display properly
- Empty states display properly

### Integration Tests
- Full user workflows
- CLI command execution
- Navigation between screens
- Theme persistence

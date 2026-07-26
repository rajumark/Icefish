# Icefish Flutter Desktop Enhancements - Implementation Plan

## Features to Implement (18 features)

### Phase 1: Core UX Improvements
1. **Keyboard Shortcuts** - Global shortcuts for major actions (Ctrl+N, Ctrl+R, Ctrl+E, etc.)
2. **Multi-window Support** - Secondary windows for emulator, screen capture, docs
3. **System Tray / Menu Bar** - Minimize to tray with quick actions
4. **Drag & Drop APK Install** - Drop APK files onto emulator/deploy screen
5. **File Picker Integration** - Native file dialogs for APKs, images, projects
6. **Right-click Context Menus** - Native context menus on lists/trees
7. **Resizable Split Panels** - Draggable dividers for sidebar/content panels
8. **Command Palette** - Ctrl+Shift+P global action search

### Phase 2: Notifications & Persistence
11. **Desktop Notifications** - Background task completion alerts
15. **Localization / i18n** - Multi-language support with intl
16. **Global Search** - Search across all features (emulators, docs, SDK, skills)
19. **Progress Persistence** - Resume interrupted downloads/operations
20. **Toast/Snackbar System** - Non-blocking feedback

### Phase 3: Advanced Features
21. **Screenshot Annotation** - Draw on screenshots before saving
22. **Batch Operation Queue** - Queue multiple installs/removals
24. **Animated Transitions** - Smooth page transitions, staggered lists
27. **Clipboard History** - History of copied IDs, paths, commands
29. **Pin Favorites to Navigation** - Drag favorites to nav rail

---

## Implementation Order (One by One)

### Step 1: Keyboard Shortcuts
- Add `Shortcuts` + `Actions` widget at app root
- Map shortcuts to existing actions (new project, run, emulator, etc.)
- Test: Verify shortcuts work on all platforms

### Step 2: Multi-window Support
- Add `window_manager` package
- Implement secondary window for screen capture and docs
- Test: Open/close secondary windows

### Step 3: System Tray
- Add `tray_manager` or `system_tray` package
- Implement tray icon with menu (show, start emulator, quit)
- Test: Minimize to tray, restore from tray

### Step 4: Drag & Drop APK Install
- Add `Draggable`/`DragTarget` to emulator and deploy screens
- Handle file drop events, trigger APK install
- Test: Drop APK from Finder/Explorer

### Step 5: File Picker
- Add `file_picker` package
- Integrate into create project, deploy, screen capture screens
- Test: Pick files on all platforms

### Step 6: Right-click Context Menus
- Add `flutter_context_menu` or custom `PopupMenuButton`
- Implement on emulator list, SDK packages, skills, layout tree
- Test: Right-click shows context menu with relevant actions

### Step 7: Resizable Split Panels
- Use `LayoutBuilder` + `GestureDetector` for draggable divider
- Apply to Home screen (nav rail + content), SDK screen (table + details)
- Test: Drag to resize panels, persist sizes

### Step 8: Command Palette
- Add `go_router` or custom overlay for Ctrl+Shift+P
- Index all actions from all screens
- Test: Open palette, search, execute actions

### Step 11: Desktop Notifications
- Add `flutter_local_notifications` package
- Show notifications on long operation completion
- Test: Trigger notification, click to open app

### Step 15: Localization / i18n
- Add `intl` package, generate ARB files
- Extract all hardcoded strings
- Add language selector in settings
- Test: Switch languages

### Step 16: Global Search
- Add search index across all features
- Implement search overlay (Ctrl+K or in command palette)
- Test: Search finds emulators, docs, packages, skills

### Step 19: Progress Persistence
- Persist operation state to SharedPreferences/database
- Resume SDK downloads, batch operations on restart
- Test: Kill app mid-download, restart, resume

### Step 20: Toast/Snackbar System
- Create global `ToastService` with `OverlayEntry`
- Replace inline SnackBars with toasts
- Test: All feedback shows as toasts

### Step 21: Screenshot Annotation
- Add drawing canvas overlay on screenshot preview
- Tools: arrow, rectangle, text, pen
- Save annotated image
- Test: Capture, annotate, save

### Step 22: Batch Operation Queue
- Create `OperationQueue` service
- Queue install/remove/update operations
- Process sequentially with progress
- Test: Queue multiple SDK installs

### Step 24: Animated Transitions
- Add `PageTransitionSwitcher` for screen transitions
- Staggered animations for lists (emulators, packages)
- Test: Smooth transitions, no jank

### Step 27: Clipboard History
- Add `ClipboardService` with history storage
- Show history in command palette or dedicated panel
- Test: Copy multiple items, access history

### Step 29: Pin Favorites to Navigation
- Add "Pin to nav" action on emulators, tools
- Show pinned items in nav rail/bar
- Persist pinned items
- Test: Pin/unpin, persists across restarts

---

## Verification Checklist Per Step
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `flutter build macos` / `windows` / `linux` succeeds
- [ ] Manual test on target platform
- [ ] No regressions in existing features
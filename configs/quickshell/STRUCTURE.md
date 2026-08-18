# Project Structure

A [Quickshell](https://quickshell.org/) desktop shell configuration (Wayland/Hyprland). Entry point is `shell.qml`, which loads top-level modules onto a `ShellRoot`.

```
.
├── shell.qml           # Entry point — instantiates the top-level modules
├── modules/             # Top-level shell surfaces (windows/bars) shown in shell.qml
├── components/          # Reusable widgets composed into modules
│   ├── popups/          #   Shared popup helpers (e.g. click-outside backdrop)
│   ├── surfaces/        #   Shared surface helpers
│   └── ui/              #   Generic UI controls (buttons, sliders, dropdowns...)
├── services/            # Singleton services — system state & backend logic
├── theme/               # Singleton design tokens (colors, typography, layout...)
├── scripts/             # Dev/tooling shell scripts
└── wallpapers/          # Wallpaper image assets
```

Each directory (other than `scripts/` and `wallpapers/`) has a `qmldir` file that declares its QML types, so imports elsewhere use `import "modules"`, `import "components"`, etc.

## `modules/`

Top-level windows/surfaces assembled in `shell.qml`:

- `Bar.qml` — main status bar
- `Brightness.qml` — brightness OSD
- `Clock.qml` — clock/calendar popup
- `ControlPanel.qml` — quick-settings panel
- `Launcher.qml` — app launcher
- `Lock.qml` — lock screen
- `NotificationCenter.qml` — notification history panel
- `PowerOptions.qml` — power menu (shutdown/reboot/logout)
- `Wallpaper.qml` — wallpaper window
- `WallpaperPicker.qml` — wallpaper selection UI

## `components/`

Widgets used inside `modules/`:

- `BatteryStatus.qml`, `Bluetooth.qml`, `PowerProfiles.qml`, `Volume.qml`, `Wifi.qml` — status indicators/controls for their respective system features
- `CurrentWindow.qml` — active window title display
- `IdleInhibitor.qml` — toggle to prevent idle/screen lock
- `MediaPlayer.qml` — media player controls widget
- `NotificationBell.qml`, `NotificationCard.qml` — notification bell icon and individual notification card
- `PrivacyIndicator.qml` — mic/camera/screen-share in-use indicator
- `ScreenshotControls.qml` — screenshot action buttons
- `SystemInfo.qml`, `SystemOptions.qml`, `SystemTray.qml` — system info popup, misc system options, and system tray
- `Workspaces.qml` — workspace switcher

### `components/popups/`

- `Backdrop.qml` — full-screen transparent backdrop used by popups to close on outside click / ESC

### `components/surfaces/`

Shared helpers for popup/window surfaces (currently empty `qmldir`).

### `components/ui/`

Generic, app-agnostic controls: `Dropdown.qml`, `ProgressBar.qml`, `Slider.qml`, `StyledButton.qml`

## `services/`

Singletons (declared via `singleton` in `qmldir`) exposing system state to the rest of the shell:

- `BluetoothService.qml`, `BrightnessService.qml`, `ClockService.qml`, `LockService.qml`, `MediaService.qml`, `NotificationService.qml`, `PowerService.qml`, `VolumeService.qml`, `WallpaperService.qml`
- `Strings.qml` — shared string constants

## `theme/`

Singleton design tokens consumed across modules/components:

- `Colors.qml`, `Typography.qml`, `Shape.qml`, `Animations.qml`, `LayoutTheme.qml`
- `CalendarTheme.qml`, `LauncherTheme.qml`, `LockScreenTheme.qml`, `NotificationTheme.qml`, `WallpaperTheme.qml`, `WorkspaceTheme.qml` — per-feature theme overrides

## `scripts/`

- `qmlls.ini.sh` — generates/updates `.qmlls.ini` for the QML language server
- `tests/notifications.sh` — manual test script for the notification system

## `wallpapers/`

Static wallpaper image assets (`.jpg`/`.png`) used by `Wallpaper.qml` / `WallpaperPicker.qml`.

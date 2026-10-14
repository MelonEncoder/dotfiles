# Project Structure

A [Quickshell](https://quickshell.org/) desktop shell configuration (Wayland/Hyprland). Entry point is `shell.qml`, which loads top-level modules onto a `ShellRoot`.

```
.
├── shell.qml           # Entry point — instantiates the top-level modules
├── modules/             # Top-level shell surfaces (windows/bars) shown in shell.qml
├── widgets/             # Bar/panel widgets composed into modules
├── components/          # Shared building blocks used by widgets and modules
│   ├── popups/          #   Bar-widget dropdown contents
│   ├── surfaces/        #   Shared surface helpers
│   └── ui/              #   Generic UI controls (buttons, sliders, dropdowns...)
├── services/            # Singleton services — system state & backend logic
├── theme/               # Singleton design tokens (colors, typography, layout...)
├── scripts/             # Dev/tooling shell scripts
└── wallpapers/          # Wallpaper image assets
```

Each directory (other than `scripts/` and `wallpapers/`) has a `qmldir` file that declares its QML types, so imports elsewhere use `import "modules"`, `import "../widgets"`, `import "../components/ui"`, etc.

## `modules/`

Top-level windows/surfaces assembled in `shell.qml`:

- `Bar.qml` — main status bar
- `Brightness.qml` — brightness OSD
- `Clock.qml` — clock/calendar popup
- `ControlPanel.qml` — quick-settings panel
- `Lock.qml` — lock screen
- `NotificationCenter.qml` — notification history panel
- `PowerOptions.qml` — power menu (shutdown/reboot/logout)
- `Wallpaper.qml` — wallpaper window
- `WallpaperPicker.qml` — wallpaper selection UI

## `widgets/`

Widgets used inside `modules/` (and the control panel popup):

- `BatteryStatus.qml`, `Volume.qml` — status indicators/controls for their respective system features
- `WifiNetworks.qml`, `BluetoothDevices.qml` — network/device lists shown in the control panel's expandable Wi-Fi/Bluetooth sections
- `TrayItem.qml`, `TrayItems.qml` — system tray row and the control panel's "Background Apps" list
- `CurrentWindow.qml` — active window title display
- `IdleInhibitor.qml` — toggle to prevent idle/screen lock
- `MediaPlayer.qml` — media player controls widget
- `NotificationBell.qml`, `NotificationCard.qml` — notification bell icon and individual notification card
- `PrivacyIndicator.qml` — mic/camera/screen-share in-use indicator
- `SystemInfo.qml`, `SystemOptions.qml` — system info popup and misc system options
- `Workspaces.qml` — workspace switcher

## `components/`

Shared building blocks, split into subdirectories (no types at the top level).

### `components/popups/`

Bar-widget dropdown contents (e.g. `ClockPopup.qml`, `SystemInfoPopup.qml`, `MediaPlayerPopup.qml`, `ControlPanelPopup.qml`, `NotificationCenterPopup.qml`).

### `components/surfaces/`

Shared low-level building blocks for popup/window surfaces:

- `Backdrop.qml` — full-screen darkening backdrop that closes on outside click / ESC
- `PopupSurface.qml` — reusable animated card surface for popup/dropdown panels
- `BarPopupSurface.qml` — standardized dropdown surface for bar widgets (composes `Backdrop` + a card panel + header)

### `components/ui/`

Generic, app-agnostic controls: `Dropdown.qml`, `ExpandSection.qml`, `ProgressBar.qml`, `Slider.qml`, `LabelButton.qml`, `SquareButton.qml`, `ToggleTile.qml`

## `services/`

Singletons (declared via `singleton` in `qmldir`) exposing system state to the rest of the shell:

- `AudioService.qml`, `BluetoothService.qml`, `BrightnessService.qml`, `CalendarService.qml`, `ClockService.qml`, `LockService.qml`, `MediaService.qml`, `NotificationService.qml`, `PowerService.qml`, `SystemInfoService.qml`, `WallpaperService.qml`, `WifiService.qml`
- `Strings.qml` — shared string constants

## `theme/`

Singleton design tokens consumed across modules/components:

- `Colors.qml`, `Typography.qml`, `Shape.qml`, `Animations.qml`, `LayoutTheme.qml`
- `CalendarTheme.qml`, `LockScreenTheme.qml`, `NotificationTheme.qml`, `WallpaperTheme.qml`, `WorkspaceTheme.qml` — per-feature theme overrides

## `scripts/`

- `qmlls.ini.sh` — generates/updates `.qmlls.ini` for the QML language server
- `tests/notifications.sh` — manual test script for the notification system

## `wallpapers/`

Static wallpaper image assets (`.jpg`/`.png`) used by `Wallpaper.qml` / `WallpaperPicker.qml`.

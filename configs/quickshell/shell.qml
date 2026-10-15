//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import "modules"

ShellRoot {
    // Touch SystemTray at startup so quickshell registers the
    // StatusNotifierWatcher immediately. Otherwise it only starts when the
    // control panel is first opened, and apps launched before then (Discord,
    // Spotify, other Electron/Chromium apps) find no watcher, fall back to
    // XEmbed, and never show up in the tray.
    Component.onCompleted: SystemTray.items

    Bar {}
    Lock {
        id: lock
    }
    Notifications {}
    PowerOptions {}
    Wallpaper {}
    WallpaperPicker {}
}

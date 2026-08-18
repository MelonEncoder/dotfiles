//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import "modules"

ShellRoot {
    Bar {}
    Launcher {}
    Lock {
        id: lock
    }
    NotificationCenter {}
    PowerOptions {}
    Wallpaper {}
    WallpaperPicker {}
}

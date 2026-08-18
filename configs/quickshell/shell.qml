//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import "modules"

ShellRoot {
    Bar {}
    ControlPanel {}
    Launcher {}
    Lock {
        id: lock
    }
    NotificationCenter {}
    PowerOptions {}
    Wallpaper {}
    WallpaperPicker {}
}

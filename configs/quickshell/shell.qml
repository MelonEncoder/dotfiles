//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import "modules"

ShellRoot {
    Bar {}
    Lock {
        id: lock
    }
    Notifications {}
    PowerOptions {}
    Wallpaper {}
    WallpaperPicker {}
}

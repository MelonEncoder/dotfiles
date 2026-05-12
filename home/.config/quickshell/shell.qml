//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import "components"

ShellRoot {
    Bar {}
    Launcher {}
    Lock {
        id: lock
    }
    Notifications {}
    PowerOptions {}
    Wallpaper {}
}

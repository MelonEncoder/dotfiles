pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland as QsWayland
import "../theme"
import "ui"

LabelButton {
    id: toggleButton
    property bool inhibited: false

    icon: toggleButton.inhibited ? "󰈈" : ""
    iconSize: Typography.size
    iconColor: toggleButton.inhibited ? Colors.background : Colors.text
    bordered: true

    // Overrides LabelButton's default color logic: `active` normally maps
    // to Colors.surfacePressed, but inhibited state needs its own inverted
    // (text-on-background) highlight instead.
    color: toggleButton.pressed
        ? Colors.surfacePressed
        : (toggleButton.inhibited
            ? Colors.text
            : (toggleButton.hovered ? Colors.surfaceHover : Colors.surface))

    onClicked: toggleButton.inhibited = !toggleButton.inhibited

    // `window` must be QsWindow (Quickshell's window wrapper), not QtQuick's Window -- the latter is silently ignored by the compositor.
    QsWayland.IdleInhibitor {
        window: toggleButton.QsWindow.window
        enabled: toggleButton.inhibited
    }
}

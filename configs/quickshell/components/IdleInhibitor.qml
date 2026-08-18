pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland as QsWayland
import "../theme"
import "ui"

StyledButton {
    id: toggleButton
    property bool inhibited: false

    icon: toggleButton.inhibited ? "󰈈" : ""
    iconSize: Typography.size
    iconColor: toggleButton.inhibited ? Colors.background : Colors.text
    bordered: true

    // Overrides StyledButton's default color logic: `active` normally maps
    // to Colors.surfacePressed, but inhibited state needs its own inverted
    // (text-on-background) highlight instead.
    color: toggleButton.pressed
        ? Colors.surfacePressed
        : (toggleButton.inhibited
            ? Colors.text
            : (toggleButton.hovered ? Colors.surfaceHover : Colors.surface))

    onClicked: toggleButton.inhibited = !toggleButton.inhibited

    Loader {
        active: toggleButton.inhibited
        sourceComponent: QsWayland.IdleInhibitor {
            window: toggleButton.Window.window
        }
    }
}

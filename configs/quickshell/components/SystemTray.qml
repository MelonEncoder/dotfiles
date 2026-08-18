pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "popups"
import "../theme"

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: label.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: LayoutTheme.barWidgetHeight
    radius: Shape.radiusNormal
    color: root.pressed ? Colors.surfacePressed : (root.hovered ? Colors.surfaceHover : Colors.surface)
    border.width: Shape.borderWidth
    border.color: Colors.border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.expanded ? "" : ""
        color: Colors.text
        font.pixelSize: Typography.size
        font.family: Typography.iconFamily
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    HyprlandFocusGrab {
        active: root.expanded && !dropdown.menuOpen
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    SystemTrayPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        onClose: root.expanded = false
    }
}

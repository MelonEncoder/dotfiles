pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland as QsWayland
import "../theme"

Rectangle {
    id: toggleButton
    property bool inhibited: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: label.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: LayoutTheme.barWidgetHeight
    radius: Shape.radiusNormal
    color: toggleButton.pressed ? Colors.surfacePressed : (toggleButton.inhibited ? Colors.text : (toggleButton.hovered ? Colors.surfaceHover : Colors.surface))
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
        text: toggleButton.inhibited ? "󰈈" : ""
        color: toggleButton.inhibited ? Colors.background : Colors.text
        font.pixelSize: Typography.size
        font.family: Typography.iconFamily
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleButton.inhibited = !toggleButton.inhibited
    }

    Loader {
        active: toggleButton.inhibited
        sourceComponent: QsWayland.IdleInhibitor {
            window: toggleButton.Window.window
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland as QsWayland
import ".."

Rectangle {
    id: toggleButton
    property bool inhibited: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: label.implicitWidth + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height
    radius: Theme.radius_normal
    color: toggleButton.pressed ? Theme.color_surface_pressed : (toggleButton.inhibited ? Theme.color_text : (toggleButton.hovered ? Theme.color_surface_hover : Theme.color_surface))
    border.width: Theme.border_width
    border.color: Theme.color_border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easing_standard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: toggleButton.inhibited ? "󰈈" : ""
        color: toggleButton.inhibited ? Theme.color_background : Theme.color_text
        font.pixelSize: Theme.font_size
        font.family: Theme.font_family_icon
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

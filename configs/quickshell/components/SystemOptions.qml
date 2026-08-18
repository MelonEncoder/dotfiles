pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import ".."

Rectangle {
    id: root
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    readonly property int iconSpacing: 4
    readonly property int slotSize: Math.max(1, Theme.bar_widget_icon_size)

    implicitWidth: (slotSize * 3) + (iconSpacing * 2) + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height
    radius: Theme.radius_normal
    color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
    border.width: Theme.border_width
    border.color: Theme.color_border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easing_standard
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: root.iconSpacing

        Repeater {
            model: ["󰖩", "󰕾", "󰂱"]
            Item {
                required property string modelData
                width: root.slotSize
                height: root.slotSize

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size_icon
                    font.family: Theme.font_family_icon
                }
            }
        }
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: openProcess.running = true
    }

    Process {
        id: openProcess
        command: ["qs", "ipc", "call", "system-options", "open"]
    }
}

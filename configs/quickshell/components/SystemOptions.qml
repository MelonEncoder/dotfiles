pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    readonly property int iconSpacing: 4
    readonly property int slotSize: Math.max(1, LayoutTheme.barWidgetIconSize)

    implicitWidth: (slotSize * 3) + (iconSpacing * 2) + (LayoutTheme.barWidgetPadding * 2)
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
                    color: Colors.text
                    font.pixelSize: Typography.icon
                    font.family: Typography.iconFamily
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

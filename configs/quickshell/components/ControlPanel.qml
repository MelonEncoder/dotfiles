pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "popups"
import "../theme"

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    // Bar.qml instantiates one ControlPanel per screen and passes its
    // screen in here. The global shortcut and IPC target must be
    // registered exactly once, so only the instance on the primary
    // screen owns them.
    required property var screen
    readonly property bool isPrimaryScreen: Quickshell.screens.length > 0 && root.screen === Quickshell.screens[0]

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
        onClicked: root.expanded = !root.expanded
    }

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    ControlPanelPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        onClose: root.expanded = false
    }

    Loader {
        active: root.isPrimaryScreen

        sourceComponent: Item {
            GlobalShortcut {
                appid: "quickshell"
                name: "system-options"
                description: "Open the system settings panel"
                triggerDescription: "SUPER+SHIFT+O"
                onPressed: root.expanded = !root.expanded
            }

            IpcHandler {
                target: "system-options"
                function open(): void {
                    root.expanded = true;
                }
            }
        }
    }
}

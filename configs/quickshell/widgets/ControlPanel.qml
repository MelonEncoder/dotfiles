pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../components/popups"
import "../components/ui"
import "../theme"

BarButton {
    id: root

    // Bar.qml instantiates one ControlPanel per screen and passes its
    // screen in here. The global shortcut and IPC target must be
    // registered exactly once, so only the instance on the primary
    // screen owns them.
    required property var screen
    readonly property bool isPrimaryScreen: Quickshell.screens.length > 0 && root.screen === Quickshell.screens[0]

    readonly property int iconSpacing: 4
    readonly property int slotSize: Math.max(1, LayoutTheme.barWidgetIconSize)

    implicitWidth: (slotSize * 3) + (iconSpacing * 2) + (LayoutTheme.barWidgetPadding * 2)
    // ControlPanelPopup exposes menuOpen, which pauses BarButton's focus
    // grab while a tray menu is open.
    popup: ControlPanelPopup {}

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

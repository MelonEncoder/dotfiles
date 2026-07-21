pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool visible: false
    property int focusedIndex: -1
    readonly property int gridColumns: 5
    readonly property int cellSize: 150

    readonly property var actions: [
        {
            action: "lock",
            iconName: "system-lock-screen"
        },
        {
            action: "logout",
            iconName: "system-log-out"
        },
        {
            action: "suspend",
            iconName: "system-suspend"
        },
        {
            action: "reboot",
            iconName: "system-reboot"
        },
        {
            action: "poweroff",
            iconName: "system-shutdown"
        },
    ]

    function open(): void {
        root.visible = true;
        root.focusedIndex = 0;
    }

    function close(): void {
        root.visible = false;
        root.focusedIndex = -1;
    }

    function runAction(action: string): void {
        root.close();
        if (action === "poweroff")
            poweroffProcess.running = true;
        else if (action === "reboot")
            rebootProcess.running = true;
        else if (action === "suspend")
            suspendProcess.running = true;
        else if (action === "logout")
            logoutProcess.running = true;
        else if (action === "lock")
            lockProcess.running = true;
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "power-menu"
        description: "Open the power options menu"
        triggerDescription: "SUPER+SHIFT+E"
        onPressed: root.visible ? root.close() : root.open()
    }

    IpcHandler {
        target: "power-options"
        function open(): void {
            root.open();
        }
    }

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]
    }
    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }
    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }
    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }
    Process {
        id: lockProcess
        command: ["qs", "ipc", "call", "lock", "lock"]
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: powerWindows.instances
        onCleared: root.close()
    }

    Variants {
        id: powerWindows
        model: root.visible ? Quickshell.screens : []

        PanelWindow {
            id: win
            required property var modelData

            screen: modelData
            visible: root.visible
            color: "transparent"
            focusable: root.visible
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            Rectangle {
                anchors.fill: parent
                color: Theme.launcher_overlay
                opacity: root.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easing_standard
                    }
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: root.cellSize * 5
                height: panelContent.implicitHeight + (Theme.bar_widget_padding * 2)
                radius: Theme.radius_background
                color: Theme.color_background
                border.width: Theme.border_width
                border.color: Theme.color_border
                opacity: root.visible ? 1 : 0
                scale: root.visible ? 1 : Animations.dropdown_scale_closed
                transformOrigin: Item.Center
                z: 1
                focus: root.visible

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easing_standard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easing_emphasized
                    }
                }

                Keys.onPressed: event => {
                    var count = root.actions.length;
                    var cols = root.gridColumns;
                    var idx = root.focusedIndex < 0 ? 0 : root.focusedIndex;
                    switch (event.key) {
                    case Qt.Key_Right:
                    case Qt.Key_Tab:
                        root.focusedIndex = (idx + 1) % count;
                        break;
                    case Qt.Key_Left:
                    case Qt.Key_Backtab:
                        root.focusedIndex = (idx - 1 + count) % count;
                        break;
                    case Qt.Key_Down:
                        root.focusedIndex = Math.min(idx + cols, count - 1);
                        break;
                    case Qt.Key_Up:
                        root.focusedIndex = Math.max(idx - cols, 0);
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        if (root.focusedIndex >= 0)
                            root.runAction(root.actions[root.focusedIndex].action);
                        break;
                    case Qt.Key_Escape:
                        root.close();
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                GridLayout {
                    id: panelContent
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.bar_widget_padding
                    columns: root.gridColumns
                    rowSpacing: 4
                    columnSpacing: 4

                    Text {
                        Layout.columnSpan: root.gridColumns
                        Layout.fillWidth: true
                        text: Strings.tr(Strings.keys.system)
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_xs
                        font.family: Theme.font_family
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1
                        leftPadding: 2
                        bottomPadding: 2
                    }

                    Rectangle {
                        Layout.columnSpan: root.gridColumns
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.color_border_subtle
                    }

                    Repeater {
                        model: root.actions

                        Rectangle {
                            id: optionItem
                            required property var modelData
                            required property int index
                            readonly property bool focused: root.focusedIndex === index
                            property bool hovered: optionMouse.containsMouse
                            property bool pressed: optionMouse.pressed

                            Layout.fillWidth: true
                            Layout.preferredHeight: root.cellSize
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered || focused ? Theme.color_surface_hover : "transparent")
                            clip: true

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            // Keyboard focus accent bar
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 2
                                color: Theme.color_purple
                                opacity: optionItem.focused ? 1 : 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Animations.duration_hover
                                        easing.type: Animations.easing_standard
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    source: "image://icon/" + optionItem.modelData.iconName
                                    sourceSize.width: 48
                                    sourceSize.height: 48
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: Strings.tr(Strings.keys["power_" + optionItem.modelData.action])
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size
                                    font.family: Theme.font_family
                                }
                            }

                            MouseArea {
                                id: optionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.focusedIndex = optionItem.index
                                onClicked: root.runAction(optionItem.modelData.action)
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                z: 0
                onClicked: root.close()
            }
        }
    }
}

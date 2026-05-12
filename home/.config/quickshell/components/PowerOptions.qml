pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "."

Scope {
    id: root

    property bool visible: false

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
    }

    function close(): void {
        root.visible = false;
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
                width: 420
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

                Keys.onEscapePressed: root.close()

                GridLayout {
                    id: panelContent
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.bar_widget_padding
                    columns: 3
                    rowSpacing: 4
                    columnSpacing: 4

                    Text {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: Strings.tr.system
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_xs
                        font.family: Theme.font_family
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1
                        leftPadding: 2
                        bottomPadding: 2
                    }

                    Rectangle {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.color_border_subtle
                    }

                    Repeater {
                        model: root.actions

                        Rectangle {
                            id: optionItem
                            required property var modelData
                            property bool hovered: optionMouse.containsMouse
                            property bool pressed: optionMouse.pressed

                            Layout.fillWidth: true
                            Layout.preferredHeight: 144
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
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
                                    text: Strings.tr["power_" + optionItem.modelData.action]
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

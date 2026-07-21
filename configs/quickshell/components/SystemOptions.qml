pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "system_options"

Scope {
    id: root

    property bool visible: false

    function open(): void {
        root.visible = true;
    }

    function close(): void {
        root.visible = false;
    }

    IpcHandler {
        target: "system-options"
        function open(): void {
            root.open();
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "system-options"
        description: "Open the system settings panel"
        triggerDescription: "SUPER+SHIFT+O"
        onPressed: root.visible ? root.close() : root.open()
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: settingsWindows.instances
        onCleared: root.close()
    }

    Variants {
        id: settingsWindows
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
                width: 360
                height: Math.min(titleBar.height + panelContent.implicitHeight + (Theme.bar_widget_padding * 2), win.height - 80)
                radius: Theme.radius_background
                color: Theme.color_background
                border.width: Theme.border_width
                border.color: Theme.color_border
                opacity: root.visible ? 1 : 0
                scale: root.visible ? 1 : Animations.dropdown_scale_closed
                transformOrigin: Item.Center
                z: 1
                focus: root.visible
                clip: true

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

                Rectangle {
                    id: titleBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 44
                    color: "transparent"
                    z: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.bar_widget_padding + 2
                        anchors.rightMargin: Theme.bar_widget_padding
                        spacing: 8

                        Text {
                            text: "󰒓"
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Strings.tr(Strings.keys.quick_settings)
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                            font.weight: Font.Medium
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: Theme.radius_normal
                            color: closeBtnHover.containsMouse ? Theme.color_surface_hover : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Theme.color_text_subtle
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family_icon
                            }

                            MouseArea {
                                id: closeBtnHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.close()
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.bar_widget_padding
                        anchors.rightMargin: Theme.bar_widget_padding
                        height: 1
                        color: Theme.color_border_subtle
                    }
                }

                Flickable {
                    anchors.top: titleBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    contentHeight: panelContent.implicitHeight + (Theme.bar_widget_padding * 2)
                    clip: true

                    ColumnLayout {
                        id: panelContent
                        width: parent.width - (Theme.bar_widget_padding * 2)
                        x: Theme.bar_widget_padding
                        y: Theme.bar_widget_padding
                        spacing: 6

                        Screenshot {
                            Layout.fillWidth: true
                        }
                        Brightness {
                            Layout.fillWidth: true
                            panelScreenName: win.modelData && win.modelData.name ? win.modelData.name : ""
                        }
                        Volume {
                            Layout.fillWidth: true
                        }
                        Wifi {
                            Layout.fillWidth: true
                        }
                        Bluetooth {
                            Layout.fillWidth: true
                        }
                        PowerProfiles {
                            Layout.fillWidth: true
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

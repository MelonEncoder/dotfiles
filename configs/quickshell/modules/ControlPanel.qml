pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

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
        target: "control-panel"
        function open(): void {
            root.open();
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "control-panel"
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
                color: LauncherTheme.overlay
                opacity: root.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: 360
                height: Math.min(titleBar.height + panelContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2), win.height - 80)
                radius: Shape.radiusBackground
                color: Colors.background
                border.width: Shape.borderWidth
                border.color: Colors.border
                opacity: root.visible ? 1 : 0
                scale: root.visible ? 1 : Animations.dropdownScaleClosed
                transformOrigin: Item.Center
                z: 1
                focus: root.visible
                clip: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easingEmphasized
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
                        anchors.leftMargin: LayoutTheme.barWidgetPadding + 2
                        anchors.rightMargin: LayoutTheme.barWidgetPadding
                        spacing: 8

                        Text {
                            text: "󰒓"
                            color: Colors.text
                            font.pixelSize: Typography.icon
                            font.family: Typography.iconFamily
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Strings.tr(Strings.keys.quick_settings)
                            color: Colors.text
                            font.pixelSize: Typography.size
                            font.family: Typography.family
                            font.weight: Font.Medium
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: Shape.radiusNormal
                            color: closeBtnHover.containsMouse ? Colors.surfaceHover : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easingStandard
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Colors.textSubtle
                                font.pixelSize: Typography.size
                                font.family: Typography.iconFamily
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
                        anchors.leftMargin: LayoutTheme.barWidgetPadding
                        anchors.rightMargin: LayoutTheme.barWidgetPadding
                        height: 1
                        color: Colors.borderSubtle
                    }
                }

                Flickable {
                    anchors.top: titleBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    contentHeight: panelContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
                    clip: true

                    ColumnLayout {
                        id: panelContent
                        width: parent.width - (LayoutTheme.barWidgetPadding * 2)
                        x: LayoutTheme.barWidgetPadding
                        y: LayoutTheme.barWidgetPadding
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

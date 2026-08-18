pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"
import "../components"
import "../components/surfaces"
import "../components/ui"

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
                color: LauncherTheme.overlay
                opacity: root.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }
            }

            PopupSurface {
                id: panel
                anchors.centerIn: parent
                width: 360
                height: Math.min(titleBar.height + panelContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2), win.height - 80)
                closedOffsetY: 0
                z: 1
                expanded: root.visible

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

                        LabelButton {
                            Layout.alignment: Qt.AlignVCenter
                            size: 24
                            icon: "󰅖"
                            iconSize: Typography.size
                            iconColor: Colors.textSubtle
                            baseColor: "transparent"
                            onClicked: root.close()
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

                        ScreenshotControls {
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

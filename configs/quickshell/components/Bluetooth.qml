pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"
import "ui"

Dropdown {
    id: root

    icon: BluetoothService.enabled ? "󰂱" : "󰂲"
    title: Strings.tr(Strings.keys.bluetooth)
    subtitle: BluetoothService.enabled
        ? Strings.tr(Strings.keys.bt_on)
        : Strings.tr(Strings.keys.bt_off)

    onToggled: expanded => {
        if (expanded)
            BluetoothService.discover();
    }

    Text {
        text: Strings.tr(Strings.keys.connected)

        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family

        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        model: BluetoothService.getConnectedDevices()

        Rectangle {
            id: connectedBtDevice

            required property var modelData

            property bool hovered:
                connectedDeviceMouse.containsMouse

            property bool pressed:
                connectedDeviceMouse.pressed

            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight

            radius: Shape.radiusNormal

            color: pressed
                ? Colors.surfacePressed
                : hovered
                    ? Colors.surfaceHover
                    : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Image {
                id: connectedDeviceIcon

                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                source: Quickshell.iconPath(
                    connectedBtDevice.modelData.icon
                )

                width: Typography.icon
                height: Typography.icon

                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.left: connectedDeviceIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                text: connectedBtDevice.modelData.name

                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family

                elide: Text.ElideRight
            }

            MouseArea {
                id: connectedDeviceMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    BluetoothService.disconnect(
                        connectedBtDevice.modelData
                    )
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: LayoutTheme.barWidgetHeight

        radius: Shape.radiusNormal
        color: "transparent"

        visible:
            BluetoothService.getConnectedDevices().length === 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text:
                !BluetoothService.available
                    ? Strings.tr(Strings.keys.bt_unavailable)
                    : BluetoothService.enabled
                        ? Strings.tr(Strings.keys.none_connected)
                        : Strings.tr(Strings.keys.bt_disabled)

            color: Colors.textSubtle
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }

    Text {
        text: Strings.tr(Strings.keys.available)

        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family

        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        model: BluetoothService.getAvailableDevices()

        Rectangle {
            id: availableBtDevice

            required property var modelData

            property bool hovered:
                availableDeviceMouse.containsMouse

            property bool pressed:
                availableDeviceMouse.pressed

            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight

            radius: Shape.radiusNormal

            color: pressed
                ? Colors.surfacePressed
                : hovered
                    ? Colors.surfaceHover
                    : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Image {
                id: availableDeviceIcon

                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                source: Quickshell.iconPath(
                    availableBtDevice.modelData.icon
                )

                width: Typography.icon
                height: Typography.icon

                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.left: availableDeviceIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                text: availableBtDevice.modelData.name

                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family

                elide: Text.ElideRight
            }

            MouseArea {
                id: availableDeviceMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    BluetoothService.connect(
                        availableBtDevice.modelData
                    )
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: LayoutTheme.barWidgetHeight

        radius: Shape.radiusNormal
        color: "transparent"

        visible:
            BluetoothService.getAvailableDevices().length === 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text:
                !BluetoothService.available
                    ? Strings.tr(Strings.keys.bt_unavailable)
                    : BluetoothService.enabled
                        ? BluetoothService.discovering
                            ? Strings.tr(Strings.keys.scanning)
                            : Strings.tr(Strings.keys.none_available)
                        : Strings.tr(Strings.keys.bt_disabled)

            color: Colors.textSubtle
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }
}

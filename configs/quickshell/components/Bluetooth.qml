pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme" as Theme
import "../services"

Rectangle {
    id: root

    property bool expanded: false

    readonly property int sectionMargin:
        Math.round(LayoutTheme.barWidgetPadding / 2)

    readonly property int expandedContentHeight:
        bluetoothExpandedContent.implicitHeight

    implicitWidth: 280
    implicitHeight: btFrame.implicitHeight + (sectionMargin * 2)

    width: implicitWidth
    height: implicitHeight

    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    radius: Shape.radiusNormal
    color: Colors.surface

    Item {
        id: btFrame

        x: root.sectionMargin
        y: root.sectionMargin

        width: parent.width - (root.sectionMargin * 2)

        implicitHeight: btMenu.implicitHeight

        ColumnLayout {
            id: btMenu

            width: parent.width
            spacing: 4

            Rectangle {
                id: bluetoothHeader

                property bool hovered: bluetoothHeaderMouse.containsMouse
                property bool pressed: bluetoothHeaderMouse.pressed

                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5

                radius: Shape.radiusNormal
                color: pressed
                    ? Colors.surfacePressed
                    : Colors.surfaceHover

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easingStandard
                    }
                }

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: 10
                        rightMargin: 10
                    }

                    spacing: 12

                    Text {
                        text: BluetoothService.enabled ? "󰂱" : "󰂲"

                        color: Colors.text
                        font.pixelSize: Typography.icon
                        font.family: Typography.iconFamily

                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        spacing: 1

                        Text {
                            text: Strings.tr(Strings.keys.bluetooth)

                            color: Colors.text
                            font.pixelSize: Typography.size
                            font.family: Typography.family
                        }

                        Text {
                            text: BluetoothService.enabled
                                ? Strings.tr(Strings.keys.bt_on)
                                : Strings.tr(Strings.keys.bt_off)

                            color: Colors.textSubtle
                            font.pixelSize: Typography.size
                            font.family: Typography.family

                            elide: Text.ElideRight
                            width: Math.max(0, bluetoothHeader.width - 60)
                        }
                    }
                }

                MouseArea {
                    id: bluetoothHeaderMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.expanded = !root.expanded;

                        if (root.expanded)
                            BluetoothService.discover();
                    }
                }
            }

            Item {
                visible: root.expanded || opacity > 0.01

                Layout.fillWidth: true
                Layout.preferredHeight:
                    root.expanded ? root.expandedContentHeight : 0

                implicitHeight:
                    root.expanded ? root.expandedContentHeight : 0

                opacity: root.expanded ? 1 : 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                ColumnLayout {
                    id: bluetoothExpandedContent

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 3

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
            }
        }
    }
}

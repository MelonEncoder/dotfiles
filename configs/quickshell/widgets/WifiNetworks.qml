pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

// Wi-Fi network list (connected + available) for the control panel's
// expandable Wi-Fi section. State lives in WifiService.
ColumnLayout {
    id: root

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
        model: WifiService.connectedNetworks

        Rectangle {
            id: connectedWifiItem
            required property var modelData
            property bool hovered: connectedWifiMouse.containsMouse
            property bool pressed: connectedWifiMouse.pressed
            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight
            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: WifiService.networkName(connectedWifiItem.modelData)
                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family
                elide: Text.ElideRight
                width: parent.width - 20
            }

            MouseArea {
                id: connectedWifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: connectedWifiItem.modelData.disconnect()
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: LayoutTheme.barWidgetHeight
        radius: Shape.radiusNormal
        color: "transparent"
        visible: WifiService.connectedNetworks.length === 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: Strings.tr(Strings.keys.none_connected)
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
        model: WifiService.availableNetworks

        Rectangle {
            id: availableWifiItem
            required property var modelData
            property bool hovered: availableWifiMouse.containsMouse
            property bool pressed: availableWifiMouse.pressed
            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight
            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: WifiService.networkName(availableWifiItem.modelData)
                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family
                elide: Text.ElideRight
                width: parent.width - 20
            }

            MouseArea {
                id: availableWifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: availableWifiItem.modelData.connect()
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: LayoutTheme.barWidgetHeight
        radius: Shape.radiusNormal
        color: "transparent"
        visible: WifiService.availableNetworks.length === 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: Strings.tr(Strings.keys.none_available)
            color: Colors.textSubtle
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }
}

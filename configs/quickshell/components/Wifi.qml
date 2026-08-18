pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import "../theme"
import "../services"
import "ui"

Dropdown {
    id: root

    readonly property var wifiDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi)
                return devs[i];
        }
        return null;
    }

    readonly property var connectedNetworks: {
        if (!root.wifiDevice) return [];
        return root.wifiDevice.networks.values.filter(function(n) { return n.connected; });
    }

    readonly property var availableNetworks: {
        if (!root.wifiDevice) return [];
        return root.wifiDevice.networks.values.filter(function(n) { return !n.connected; });
    }

    function wifiName(network: var): string {
        if (!network) return "Unknown Network";
        if (network.name && network.name.length > 0) return network.name;
        return "Hidden Network";
    }

    function currentWifiSubtitle(): string {
        if (!root.wifiDevice) return "unavailable";
        if (root.wifiDevice.state === ConnectionState.Connecting) return "connecting...";
        if (root.connectedNetworks.length > 0) return root.wifiName(root.connectedNetworks[0]);
        return "none connected";
    }

    onExpandedChanged: {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = root.expanded;
    }

    icon: "󰖩"
    title: Strings.tr(Strings.keys.wifi)
    subtitle: root.currentWifiSubtitle()
    showChevron: true

    Text {
        text: Strings.tr(Strings.keys.connected)
        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family
        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        model: root.connectedNetworks

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
                text: root.wifiName(connectedWifiItem.modelData)
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
        visible: root.connectedNetworks.length === 0

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
        model: root.availableNetworks

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
                text: root.wifiName(availableWifiItem.modelData)
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
        visible: root.availableNetworks.length === 0

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

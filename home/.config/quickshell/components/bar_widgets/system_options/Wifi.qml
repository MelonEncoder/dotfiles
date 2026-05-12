pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import "../../"

Rectangle {
    id: root
    property bool expanded: false
    readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)

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

    readonly property int expandedContentHeight: wifiExpandedContent.implicitHeight

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

    implicitWidth: 280
    implicitHeight: wifiFrame.implicitHeight + (root.sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Theme.radius_normal
    color: Theme.color_surface

    Item {
        id: wifiFrame
        x: root.sectionMargin
        y: root.sectionMargin
        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: wifiMenu.implicitHeight

        ColumnLayout {
            id: wifiMenu
            width: parent.width
            spacing: 4

            Rectangle {
                id: wifiHeader
                property bool hovered: wifiHeaderMouse.containsMouse
                property bool pressed: wifiHeaderMouse.pressed
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.bar_widget_height * 1.5
                radius: Theme.radius_normal
                color: pressed ? Theme.color_surface_pressed : Theme.color_surface_hover

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easing_standard
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
                        text: "󰖩"
                        color: Theme.color_text
                        font.pixelSize: Theme.font_size_icon
                        font.family: Theme.font_family_icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: Strings.tr.wifi
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }

                        Text {
                            text: root.currentWifiSubtitle()
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                            elide: Text.ElideRight
                            width: Math.max(0, wifiHeader.width - 60)
                        }
                    }

                    Text {
                        text: root.expanded ? "" : ""
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_xs
                        font.family: Theme.font_family_icon
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: wifiHeaderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }

            Item {
                visible: root.expanded || opacity > 0.01
                Layout.fillWidth: true
                Layout.preferredHeight: root.expanded ? root.expandedContentHeight : 0
                implicitHeight: root.expanded ? root.expandedContentHeight : 0
                opacity: root.expanded ? 1 : 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                ColumnLayout {
                    id: wifiExpandedContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

                    Text {
                        text: Strings.tr.connected
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
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
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.wifiName(connectedWifiItem.modelData)
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family
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
                        Layout.preferredHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: "transparent"
                        visible: root.connectedNetworks.length === 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: Strings.tr.none_connected
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }
                    }

                    Text {
                        text: Strings.tr.available
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
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
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.wifiName(availableWifiItem.modelData)
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family
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
                        Layout.preferredHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: "transparent"
                        visible: root.availableNetworks.length === 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: Strings.tr.none_available
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }
                    }
                }
            }
        }
    }
}

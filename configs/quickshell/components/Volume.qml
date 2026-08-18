pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services/"
import "ui"

Dropdown {
    id: root

    // Local mirror of VolumeService.volume so dragging feels instant and
    // isn't fighting the (possibly slightly-lagged) Pipewire readback.
    property int currentVolume: 0

    function setDefaultSink(node: var): void {
        VolumeService.setDefaultSink(node);
        root.expanded = false;
    }

    Component.onCompleted: root.currentVolume = VolumeService.volume

    headerDelegate: Component {
        Item {
            anchors.fill: parent

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 10

                StyledButton {
                    Layout.alignment: Qt.AlignVCenter
                    baseColor: "transparent"
                    icon: !VolumeService.sink ? "" : (VolumeService.muted ? "" : "")
                    onClicked: VolumeService.toggleMute()
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    value: root.currentVolume
                    onMoved: function (percent) {
                        root.currentVolume = percent;
                        VolumeService.setVolume(percent);
                    }

                    Connections {
                        target: VolumeService
                        function onVolumeChanged() {
                            if (!volumeSlider.dragging)
                                root.currentVolume = VolumeService.volume;
                        }
                    }
                }

                StyledButton {
                    Layout.alignment: Qt.AlignVCenter
                    baseColor: "transparent"
                    active: root.expanded
                    icon: root.expanded ? "\uf077" : "\uf078"
                    iconSize: Typography.iconLg
                    iconColor: root.expanded ? Colors.text : Colors.textSubtle
                    onClicked: root.expanded = !root.expanded
                }
            }
        }
    }

    Text {
        text: Strings.tr(Strings.keys.output_devices)
        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family
        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        model: VolumeService.audioSinks

        Rectangle {
            id: deviceItem
            required property var modelData
            readonly property bool isDefault: !!VolumeService.sink && modelData.id === VolumeService.sink.id
            property bool hovered: deviceMouse.containsMouse
            property bool pressed: deviceMouse.pressed

            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight
            radius: Shape.radiusNormal
            color: deviceItem.pressed ? Colors.surfacePressed : (deviceItem.hovered || deviceItem.isDefault ? Colors.surfaceHover : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: deviceItem.isDefault ? "" : ""
                    color: deviceItem.isDefault ? Colors.text : Colors.textSubtle
                    font.pixelSize: Typography.sm
                    font.family: Typography.iconFamily
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: deviceItem.modelData.description || deviceItem.modelData.nick || deviceItem.modelData.name || "Unknown"
                    color: Colors.text
                    font.pixelSize: Typography.size
                    font.family: Typography.family
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                id: deviceMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setDefaultSink(deviceItem.modelData)
            }
        }
    }
}
